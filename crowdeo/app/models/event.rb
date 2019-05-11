class Event < ApplicationRecord
  has_many :event_attendances
  has_many :events_gender_filters

  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true

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

  def self.create_event_with_filters(event_hash, is_filter, permit_gender_id_arr)
    begin
      event = nil
      ActiveRecord::Base.transaction do
        event = Event.create(event_hash)
        if is_filter
          permit_gender_id_arr.each do |permitted_gender_id|
            EventsGenderFilter.create(event_id: event.id, gender_id: permitted_gender_id)
          end
        end
      end
      return event
    rescue
      return nil
    end
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
            .left_joins(:event_attendances)
            .left_joins(:events_gender_filters)
            .where("events.is_filter = FALSE OR events_gender_filters.gender_id = #{current_user.gender_id}")
            .where(if attending_events then "event_attendances.user_id = #{current_user.id}" else '1=1' end)
            .where(if user_events then "events.author_id = #{current_user.id}" else '1=1' end)
            .group('events.id')
            .order('events.created_at DESC, events.name ASC')
            .offset(page_items_count * (page_id - 1))
            .limit(page_items_count)
            .select(
                'events.id as event_id',
                'events.name as event_name',
                'events.description',
                'events.author_id',
                'events.created_at as event_created_at',
                'COUNT(*) FILTER (WHERE event_attendances.id IS NOT NULL) as attendance')

    unless search_name_pattern.blank?
      event_data_query = event_data_query.where("events.name LIKE ?", '%' + search_name_pattern + '%')
    end

    # adding author name
    return User
               .joins("INNER JOIN (#{event_data_query.to_sql}) as res on users.id = res.author_id")
               .order('event_created_at DESC, event_name ASC')
               .select(
                   'res.event_id',
                   'res.event_name',
                   'res.description',
                   'res.event_created_at',
                   'res.attendance',
                   'res.author_id',
                   'users.nick_name as author_nick_name')
  end
end
