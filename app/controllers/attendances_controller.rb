class AttendancesController < ApplicationController

  def attend_event
    unless logged_in?
      go_to_login
      return
    end
    #
    # todo: check if current user can attend the event
    #
    event = Event.find_by(id: params[:id])

    if event.capacity != nil and Event.get_event_attendance(event.id) < event.capacity
      flash[:danger] = "Cannot attend this event, capacity is full."
      redirect_to event_show_path(event)
    elsif EventAttendance.create(user_id: current_user.id, event_id: event.id)
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

end
