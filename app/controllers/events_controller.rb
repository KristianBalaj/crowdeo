class EventsController < ApplicationController

  # This loads all the available events to user
  def index
    unless logged_in?
      go_to_login
      return
    end

    @event_cards_data_arr = []

    page_items_count = 20
    events_count = Event.count

    #check if parameter is an integer
    @pagination =
        Pagination.new((events_count / page_items_count.to_f).ceil, params[:page].to_i, 3, method(:all_events_path))

    @event_cards_data_arr = Event.get_all_event_cards_data(@pagination.current_page, page_items_count, current_user, '')
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

    @event_cards_data_arr = Event.get_users_event_cards_data(@pagination.current_page, page_items_count, current_user)
  end

  def attending_events_index
    unless logged_in?
      go_to_login
      return
    end

    page_items_count = 5

    all_attending_events =
        Event.joins("JOIN event_attendances ea ON ea.event_id = events.id AND ea.user_id = #{current_user.id}")

    @pagination =
        Pagination.new((all_attending_events.count / page_items_count.to_f).ceil, params[:page].to_i, 3, method(:attending_events_path))

    @event_cards_data_arr = Event.get_attending_event_cards_data(@pagination.current_page, page_items_count, current_user)
  end

  def new
    @event = Event.new
  end

  def create
    unless logged_in?
      go_to_login
      return
    end

    event_hash_without_geo = permitted_event_params
    event_hash_without_geo[:author_id] = current_user.id

    lat = params[:event][:lat]
    lng = params[:event][:lng]

    @event =
        Event.create_event_with_filters(
            event_hash_without_geo,
            [lat, lng],
            !params[:event][:is_filter].to_i.zero?,
            params[:permit_gender].map(&:to_i))

    if @event.valid?
      flash[:success] = "Event created successfully."
      redirect_to event_show_path @event
    else
      render 'new'
    end
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

  def search
    @pagination =
        Pagination.new(1, 1, 3, method(:all_events_path))

    @event_cards_data_arr = Event.get_all_event_cards_data(1, 20, current_user, params[:search][:query])
    render 'events/index'
  end

  def show
    @event = Event.find(params[:id])
    @attending = EventAttendance.where(user_id: current_user.id, event_id: @event.id).exists?
    @author_nick = User.find_by(id: @event.author_id).nick_name
    @is_my_event = @event.author_id == current_user.id
  end

  def edit
    unless logged_in?
      go_to_login
      return
    end

    @event = Event.find_by(id: params[:id])

    if current_user.id != @event.author_id
      redirect_to all_events_path
    end
  end

  def update
    @event = Event.find(params[:id])
    if @event.update_attributes(permitted_event_params)
      redirect_to all_events_path
    else
      render 'edit'
    end
  end

  def delete
    unless logged_in?
      go_to_login
      return
    end

    event = Event.find_by(id: params[:id])

    if current_user.id != event.author_id
      redirect_to all_events_path
      return
    end

    if Event.delete_event(event)
      flash[:success] = 'Event deleted successfully.'
      redirect_to all_events_path
    else
      flash[:danger] = 'An error occured while deleting the event.'
      redirect_to event_show_path event
    end
  end

  private

  def permitted_event_params
    params.require(:event).permit(
        :name,
        :description,
        :start_date,
        :end_date,
        :capacity,
        :is_filter,
        :from_birth_date)
  end

  def go_to_login
    flash[:danger] = "You need to login first."
    redirect_to login_path
  end

end
