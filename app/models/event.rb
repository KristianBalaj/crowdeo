class Event < ApplicationRecord
  has_many :event_attendances
  has_many :events_gender_filters

  validates :name, presence: true, uniqueness: true
  validates :latitude, presence: true
  validates :category_id, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true

  def self.add_view(id)
    $redis.incr("events:#{id}")
  end

  def self.get_views_count(id)
    $redis.get("events:#{id}").to_i
  end

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

  def self.get_event_attendance(event_id)
    Event.where("events.id = #{event_id}")
        .select('(SELECT count(*) FROM event_attendances WHERE events.id = event_attendances.event_id) as attendance').first.attendance
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

  def self.get_events_data_json(tag_popular,
                           display_option,
                           current_user_id,
                           only_attending_events,
                           only_author_events,
                           offset,
                           lat = 0,
                           lng = 0,
                           radius = -1,
                           category_id = -1,
                           only_night = 'false',
                           only_free = 'false',
                           genders_only = -1)
    result = self.query_event_data(
        display_option,
        current_user_id,
        only_attending_events,
        only_author_events,
        offset,
        lat,
        lng,
        radius,
        category_id,
        only_night,
        only_free,
        genders_only).as_json

    sorted_area_events_by_score = []
    total_area_events_count = 0

    if tag_popular
      all_area_events = self.get_all_from_area(lat, lng, radius).as_json
      total_area_events_count = all_area_events.count
      all_area_events.each do |item|
        views_count = self.get_views_count(item['id'])
        item['attendance'] += views_count
        item['views'] = views_count
      end
      sorted_area_events_by_score = all_area_events.sort_by do |item|
        item['attendance']
      end
    end

    result.each do |item|
      author_id = item.delete "author_id"
      item[:time_to_event_text] = get_time_to_event_start_text(item['start_time'])
      item[:is_author_event] = current_user_id.to_i == author_id.to_i
      item['is_attending'] = item['is_attending'] == 1

      if tag_popular
        event_rank = sorted_area_events_by_score.index do |x| x['id'].to_i == item['id'].to_i end
        puts 'RANK ' + event_rank.to_s
        puts '> ' + (total_area_events_count * 0.8 - 1).ceil.to_s
        item[:is_popular] = event_rank != nil ? event_rank > (total_area_events_count * 0.8 - 1).ceil : false
        item[:views_count] = event_rank != nil ? sorted_area_events_by_score[event_rank]['views'] : 0
      else
        item[:is_popular] = false
        item[:views_count] = self.get_views_count(item['id'])
      end
    end

    return result.as_json
  end

  def self.get_all_from_area(lat, lng, radius)
    return Event
        .select('events.id', '(SELECT count(*) FROM event_attendances WHERE events.id = event_attendances.event_id) as attendance')
        .joins("JOIN ST_BUFFER(ST_POINT(#{lat}, #{lng})::geography, #{radius}) area ON ST_WITHIN(ST_POINT(events.latitude, events.longitude)::geography::geometry, area::geometry)")
  end

  def self.query_event_data(
              display_option,
              current_user_id,
              only_attending_events,
              only_author_events,
              offset,
              lat = 0,
              lng = 0,
              radius = -1,
              category_id = -1,
              only_night = 'false',
              only_free = 'false',
              genders_only = -1)
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
                 # "ST_DistanceSphere(ST_POINT(events.latitude, events.longitude)::geometry,ST_POINT(#{lat}, #{lng})::geometry) as dist",
                 '(SELECT count(*) FROM event_attendances WHERE events.id = event_attendances.event_id) as attendance')
    if radius.to_i != -1
      data_query =
          data_query
              .joins("JOIN ST_BUFFER(ST_POINT(#{lat}, #{lng})::geography, #{radius}) area ON ST_WITHIN(ST_POINT(events.latitude, events.longitude)::geography::geometry, area::geometry)")
    end
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
                       .order('start_time DESC')
                       .where('start_time::timestamp < ?::timestamp', Time.now.getutc)
    else # incomming events option
      data_query = data_query
                       .order('start_time ASC')
                       .where('start_time::timestamp > ?::timestamp', Time.now.getutc)

    end
    return data_query
  end
end
