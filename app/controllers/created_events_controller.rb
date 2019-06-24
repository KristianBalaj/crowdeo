include EventsHelper
include ApplicationHelper

class CreatedEventsController < ApplicationController
  def index
    unless logged_in?
      go_to_login
      return
    end
  end

  def created_events
    result = Event.get_events_data_json(
        false,
        0,
        current_user.id,
        false,
        true,
        params[:offset])

    render :json => result.to_json
  end
end
