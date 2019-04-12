class EventsController < ApplicationController

  # This loads all the available events to user
  def index
    unless logged_in?
      go_to_login
      return
    end

    @events_hash_arr = []

    Event.all.each do |event|
      @events_hash_arr.push({
                                event: event,
                                attendants_count: EventAttendance.where("event_id = #{event.id}").count,
                                author: User.find_by(id: event.author_id),
                                editable?: event.author_id == current_user.id })
    end
  end

  # This loads only the events created by current user
  def my_events_index
    unless logged_in?
      go_to_login
      return
    end

    my_events = Event.where(author_id: current_user.id).to_a
    @events_hash_arr = []

    if my_events != nil
      my_events.each do |event|
        @events_hash_arr.push({
                                  event: event,
                                  attendants_count: EventAttendance.where("event_id = #{event.id}").count,
                                  author: current_user,
                                  editable?: true })
      end
    end
  end

  def attending_events_index
    unless logged_in?
      go_to_login
      return
    end

    @events_hash_arr = []
    attending_events =
        Event.joins("JOIN event_attendances ea ON ea.event_id = events.id AND ea.user_id = #{current_user.id}").to_a

    if attending_events != nil
      attending_events.each do |event|
        @events_hash_arr.push({
                                  event: event,
                                  attendants_count: EventAttendance.where("event_id = #{event.id}").count,
                                  author: User.find_by(id: event.author_id),
                                  editable?: event.author_id == current_user.id })
      end
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
      redirect_to events_path
    else
      render 'new'
    end
  end

  def show
    @event = Event.find(params[:id])
    @attending = EventAttendance.where(user_id: current_user.id, event_id: @event.id).exists?
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
      redirect_to event
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
    redirect_to event
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
