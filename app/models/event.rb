class Event < ApplicationRecord
  has_many :event_attendances
  has_many :events_gender_filters

  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :latitude, presence: true

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

  # Gets event cards data for given page with given items per page.
  # Returned event data are for events that are attended by the user.
  # @return [Object] having attributes:
  # *event_name*, *description*, *event_id*, *event_created_at*, *attendance*, *author_nick_name*, *author_id*
  def self.get_attending_event_cards_data(page_id, page_items_count, current_user)
    event_data_to_display =
        query_event_card_data(
            page_id,
            page_items_count,
            current_user,
            true,
            false,
            '')
    return get_event_cards_data_array(event_data_to_display, current_user)
  end

  # Gets event cards data for given page with given items per page.
  # Returned event data are for events created by the user.
  # @return [Object] having attributes:
  # *event_name*, *description*, *event_id*, *event_created_at*, *attendance*, *author_nick_name*, *author_id*
  def self.get_users_event_cards_data(page_id, page_items_count, current_user)
    event_data_to_display =
        query_event_card_data(
            page_id,
            page_items_count,
            current_user,
            false,
            true,
            '')
    return get_event_cards_data_array(event_data_to_display, current_user)
  end

  # Gets event cards data for given page with given items per page.
  # @return [Object] having attributes:
  # *event_name*, *description*, *event_id*, *event_created_at*, *attendance*, *author_nick_name*, *author_id*
  def self.get_all_event_cards_data(page_id, page_items_count, current_user, search_name_pattern)
    event_data_to_display =
        query_event_card_data(
            page_id,
            page_items_count,
            current_user,
            false,
            false,
            search_name_pattern)
    return get_event_cards_data_array(event_data_to_display, current_user)
  end


  private


  def self.get_event_cards_data_array(event_data_to_display, current_user)
    event_cards_data_arr = Array.new

    event_data_to_display.each do |event_to_display|
      card_data = EventCardData.new(
          event_to_display.event_name,
          event_to_display.description,
          event_to_display.event_id,
          event_to_display.event_created_at,
          event_to_display.attendance,
          event_to_display.author_nick_name,
          event_to_display.author_id == current_user.id)

      event_cards_data_arr.push(card_data)
    end

    return event_cards_data_arr
  end

  def self.query_event_card_data(page_id, page_items_count, current_user, attending_events, user_events, search_name_pattern)
    event_data_query =
        Event
            .left_joins(:events_gender_filters)
            .joins("JOIN users ON users.id = events.author_id")
            .where("events.is_filter = FALSE OR events_gender_filters.gender_id = #{current_user.gender_id}")
            .order('events.created_at DESC, events.name ASC')
            .offset(page_items_count * (page_id - 1))
            .limit(page_items_count)
            .select(
                'events.id as event_id',
                'events.name as event_name',
                'events.description',
                'events.author_id',
                'users.nick_name as author_nick_name',
                'events.created_at as event_created_at')

    if user_events
      event_data_query = event_data_query
          .where("events.author_id = #{current_user.id}")
    elsif attending_events
      event_data_query = event_data_query
          .left_joins(:event_attendances)
          .where("event_attendances.user_id = #{current_user.id}")
    end

    unless search_name_pattern.blank?
      event_data_query = event_data_query.where("events.name LIKE ?", search_name_pattern)
    end

    where_cond = "0=1"
    event_data_query.each_with_index do |data, id|
      where_cond = where_cond + ' OR '
      where_cond = where_cond + "events.name = '#{data.event_name}'"
    end

    attendances = Event
        .left_joins(:event_attendances)
        .where(where_cond)
        .group('events.id')
        .order('events.created_at DESC, events.name ASC')
        .select('COUNT(*) FILTER (WHERE event_attendances.id IS NOT NULL) as attendance').to_a

    result = []
    event_data_query.each_with_index do |data, id|
      item = OpenStruct.new(data.attributes)
      # this condition is only because there are repeating events
      # and that causes this array be less than the event_data_query array
      # The reason is that the data generation generates repeating gender filters.
      # In real situation it can't happen.
      if attendances[id] == nil
        item.attendance = attendances[0].attendance
      else
        item.attendance = attendances[id].attendance
      end

      result.push(item)
    end

    return result
  end
end
