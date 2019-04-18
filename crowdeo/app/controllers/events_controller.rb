class EventsController < ApplicationController

  # This loads all the available events to user
  def index
    unless logged_in?
      go_to_login
      return
    end

    @event_cards_data_arr = []

    page_items_count = 20
    all_events = Event.all

    #check if parameter is an integer
    @pagination =
        Pagination.new((all_events.count / page_items_count.to_f).ceil, params[:page].to_i, 3, method(:all_events_path))

    events_to_display =
        all_events
            .order('created_at DESC')
            .offset(page_items_count * (@pagination.current_page - 1))
            .limit(page_items_count)

    #do group by for optimization - users count

    events_to_display.each do |event|
      card_data = EventCardData.new(
          event,
          EventAttendance.where("event_id = #{event.id}").count,
          User.find_by(id: event.author_id),
          event.author_id == current_user.id)

      @event_cards_data_arr.push(card_data)
    end
  end

  # This loads only the events created by current user
  def my_events_index
    unless logged_in?
      go_to_login
      return
    end


    page_items_count = 20
    all_my_events = Event.where(author_id: current_user.id)
    @event_cards_data_arr = []

    @pagination =
        Pagination.new((all_my_events.count / page_items_count.to_f).ceil, params[:page].to_i, 3, method(:my_events_path))

    events_to_display =
        all_my_events
            .order('created_at DESC')
            .offset(page_items_count * (@pagination.current_page - 1))
            .limit(page_items_count)

    events_to_display.each do |event|
      card_data = EventCardData.new(
          event,
          EventAttendance.where("event_id = #{event.id}").count,
          current_user,
          true)

      @event_cards_data_arr.push(card_data)
    end
  end

  def attending_events_index
    unless logged_in?
      go_to_login
      return
    end

    page_items_count = 5

    @event_cards_data_arr = []
    all_attending_events =
        Event.joins("JOIN event_attendances ea ON ea.event_id = events.id AND ea.user_id = #{current_user.id}")

    @pagination =
        Pagination.new((all_attending_events.count / page_items_count.to_f).ceil, params[:page].to_i, 3, method(:attending_events_path))

    events_to_display =
        all_attending_events
            .order('created_at DESC')
            .offset(page_items_count * (@pagination.current_page - 1))
            .limit(page_items_count)

    events_to_display.each do |event|
      card_data = EventCardData.new(
          event,
          EventAttendance.where("event_id = #{event.id}").count,
          User.find_by(id: event.author_id),
          event.author_id == current_user.id)

      @event_cards_data_arr.push(card_data)
    end
  end

  def new
    @event = Event.new
  end

  def create
    unless logged_in?
      go_to_login
      return
    end

    event_hash = event_params
    event_hash[:author_id] = current_user.id
    @event = Event.new(event_hash)

    if @event.save
      flash[:success] = "Event created successfully."
      redirect_to event_show_path @event
    else
      render 'new'
    end
  end

  def show
    @event = Event.find(params[:id])
    @attending = EventAttendance.where(user_id: current_user.id, event_id: @event.id).exists?
    @author_nick = User.find_by(id: @event.author_id).nick_name
  end

  def attend_event
    unless logged_in?
      go_to_login
      return
    end
    #
    # todo: check if current user can attend the event
    #
    event = Event.find_by(id: params[:id])

    if EventAttendance.create(user_id: current_user.id, event_id: event.id)
      flash[:success] = "Event attend confirmed."
      redirect_to event_show_path(event)
    end

  end

  def unattend_event
    unless logged_in?
      go_to_login
      return
    end

    event = Event.find_by(id: params[:id])
    EventAttendance.where(user_id: current_user.id, event_id: event.id).first.destroy
    flash[:success] = "Event unattend confirmed."
    redirect_to event_show_path(event)
  end

  def edit
    unless logged_in?
      go_to_login
      return
    end

    @event = Event.find_by(id: params[:id])

    if current_user.id != @event.author_id
      redirect_to events_path
    end
  end

  private

  def event_params
    params.require(:event).permit(
        :name,
        :description,
        :start_date,
        :end_date,
        :capacity,
        :is_filter?,
        :from_birth_date)
  end

  def go_to_login
    flash[:danger] = "You need to login first."
    redirect_to login_path
  end

end
