include EventsHelper
include ApplicationHelper

class EventsController < ApplicationController

  # This loads all the available events to user
  def index
    unless logged_in?
      go_to_login
      return
    end
    @genders_arr = Gender.all.map {|g| [g.gender_tag.capitalize, g.id]}
    @genders_arr = @genders_arr.unshift ['All', -1]
  end

  def new
    unless logged_in?
      go_to_login
      return
    end
    @dates = OpenStruct.new
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
    if event_hash_without_geo[:category_id] == '-1'
      event_hash_without_geo[:category_id] = ''
    end
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
      @dates = OpenStruct.new(params[:dates])
      render 'new'
    end
  end

  def show
    @event = Event.find(params[:id])
    @is_attending = EventAttendance.where(user_id: current_user.id, event_id: @event.id).exists?
    @author_nick = User.find_by(id: @event.author_id).nick_name
    @is_my_event = @event.author_id == current_user.id

    Event.add_view @event.id
  end

  def edit
    unless logged_in?
      go_to_login
      return
    end

    @event = Event.find_by(id: params[:id])

    if current_user.id != @event.author_id
      flash[:danger] = 'Cannot modify event you don\'t own.'
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
    result = Event.get_events_data_json(
        true,
        params[:display_by],
        current_user.id,
        false,
        false,
        params[:offset],
        params[:lat],
        params[:lng],
        params[:radius],
        params[:category],
        params[:only_night],
        params[:only_free],
        params[:genders_only])

    render :json => result.to_json
  end

  private

  def permitted_event_params
    params.require(:event).permit(
        :name,
        :description,
        :capacity,
        :is_filter,
        :from_birth_date,
        :is_free,
        :is_night,
        :tags,
        :category_id,
        :start_time,
        :end_time)
  end

end
