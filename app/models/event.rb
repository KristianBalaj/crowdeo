class Event < ApplicationRecord
  has_many :event_attendances
  has_many :events_gender_filters

  validates :name, presence: true
  validates :latitude, presence: true
  validates :category_id, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true

  # @return [Boolean] true when deletion completed successfully otherwise false
  def self.delete_event(event_to_delete)
    begin
      ActiveRecord::Base.transaction do
        EventsGenderFilter.where("events_gender_filters.event_id = #{event_to_delete.id}").destroy_all
        EventAttendance.where("event_attendances.event_id = #{event_to_delete.id}").destroy_all
        event_to_delete.destroy
      end
    rescue
      return false
    end
    return true
  end

  def self.create_event_with_filters(event_hash, lat_lng_arr, is_filter, permit_gender_id_arr)
    event = nil
    ActiveRecord::Base.transaction do
      event = Event.new(event_hash)
      begin
        lat = Float(lat_lng_arr[0])
        lng = Float(lat_lng_arr[1])
        event.latitude = lat
        event.longitude = lng
      rescue
        event.latitude = nil
        event.longitude = nil
      end
      if is_filter
        permit_gender_id_arr.each do |permitted_gender_id|
          EventsGenderFilter.create(event_id: event.id, gender_id: permitted_gender_id)
        end
      end
      event.save
    end
    return event
  end

  def self.query_event_data(display_option, current_user_id, only_attending_events, only_author_events, offset, lat, lng, category_id, only_night, only_free, genders_only)
    data_query = Event
               .joins('JOIN users ON events.author_id = users.id')
               .offset(offset)
               .limit(6)
               .select('events.id',
                 'events.name',
                 'events.is_free',
                 'events.is_night',
                 'events.tags',
                 'events.capacity',
                 'events.description',
                 'events.start_time',
                 'users.nick_name as author_nick',
                 'events.author_id',
                 "(SELECT count(*) FROM event_attendances ea WHERE ea.event_id = events.id AND ea.user_id = #{current_user_id}) as is_attending",
                 "ST_DistanceSphere(ST_POINT(events.latitude, events.longitude)::geometry,ST_POINT(#{lat}, #{lng})::geometry) as dist",
                 '(SELECT count(*) FROM event_attendances WHERE events.id = event_attendances.event_id) as attendance')
    if genders_only.to_i != -1
      data_query =
          data_query
              .where('(SELECT count(*) FROM events_gender_filters egf WHERE events.id = egf.event_id) = 1')
              .where('(SELECT count(*) FROM events_gender_filters egf WHERE events.id = egf.event_id AND egf.gender_id = ?) = 1', genders_only)
    end
    if category_id.to_i != -1 then data_query = data_query.where 'events.category_id = ?', category_id end
    if only_night.eql? 'true' then data_query = data_query.where 'events.is_night = ?', true end
    if only_free.eql? 'true' then data_query = data_query.where 'events.is_free = ?', true end
    if only_attending_events
      data_query = data_query
                       .left_joins(:event_attendances)
                       .where('event_attendances.user_id = ?', current_user_id)
    elsif only_author_events
      data_query = data_query.where('events.author_id = ?', current_user_id)
    end

    # history events option
    if display_option.to_i == 1
      data_query = data_query
                       .order('dist ASC, start_time DESC')
                       .where('start_time::timestamp < ?::timestamp', Time.now.getutc)
    else # incomming events option
      data_query = data_query
                       .order('dist ASC')
                       .where('start_time::timestamp > ?::timestamp', Time.now.getutc)

    end
    return data_query
  end
end
