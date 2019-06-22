include EventsHelper

class EventsController < ApplicationController

  # This loads all the available events to user
  def index
    unless logged_in?
      go_to_login
      return
    end
    @categories_arr = Category.all.map {|c| [c.name, c.id]}
    @categories_arr = @categories_arr.unshift ['All', -1]
    @genders_arr = Gender.all.map {|g| [g.gender_tag.capitalize, g.id]}
    @genders_arr = @genders_arr.unshift ['All', -1]
  end

  # This loads only the events created by current user
  def my_events_index
    unless logged_in?
      go_to_login
      return
    end
  end

  def attending_events_index
    unless logged_in?
      go_to_login
      return
    end
  end

  def new
    unless logged_in?
      go_to_login
      return
    end
    @event = Event.new
    @categories_arr = Category.all.map {|c| [c.name, c.id]}
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
    @is_attending = EventAttendance.where(user_id: current_user.id, event_id: @event.id).exists?
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

  def closest_events
    result = Event.query_event_data(
        current_user.id,
        false,
        false,
        params[:offset],
        params[:lat],
        params[:lng],
        params[:category],
        params[:only_night],
        params[:only_free],
        params[:genders_only]).as_json
    result.each do |item|
      author_id = item.delete "author_id"
      start_date = item.delete "start_date"
      start_time = item.delete "start_time"
      item[:time_to_event_text] = get_created_ago_text(get_full_dateTime start_date, start_time)
      item[:is_popular] = if rand < 0.5 then true else false end
      item[:is_author_event] = current_user.id == author_id
      item['is_attending'] = item['is_attending'] == 1
    end

    render :json => result.to_json
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
        :from_birth_date,
        :start_time,
        :end_time,
        :is_free,
        :is_night,
        :tags)
  end

  def go_to_login
    flash[:danger] = "You need to login first."
    redirect_to login_path
  end

end
