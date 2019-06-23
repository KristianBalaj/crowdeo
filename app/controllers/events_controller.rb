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

    $redis.incr("events:#{params[:id]}")
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
        params[:genders_only]).as_json

    all_area_events = Event.get_all_from_area(params[:lat],
                            params[:lng],
                            params[:radius]).as_json
    total_area_events_count = all_area_events.count

    all_area_events.each do |item|
      views_count = $redis.get("events:#{item['id']}").to_i
      puts views_count
      item['attendance'] += views_count
      item['views'] = views_count
    end

    sorted_area_events_by_score = all_area_events.sort_by do |item|
      item['attendance']
    end

    result.each do |item|
      author_id = item.delete "author_id"
      item[:time_to_event_text] = get_starts_in_text(item['start_time'])
      item[:is_popular] = if rand < 0.5 then true else false end
      item[:is_author_event] = current_user.id == author_id
      item['is_attending'] = item['is_attending'] == 1
      event_rank = sorted_area_events_by_score.index do |x| x['id'].to_i == item['id'].to_i end
      item[:is_popular] = event_rank != nil ? event_rank > (total_area_events_count * 0.8 - 1).ceil : false
      item[:views_count] = event_rank != nil ? sorted_area_events_by_score[event_rank]['views'] : 0
    end

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
