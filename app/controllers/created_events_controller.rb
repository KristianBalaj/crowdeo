include EventsHelper

class CreatedEventsController < ApplicationController
  def index
    unless logged_in?
      go_to_login
      return
    end
  end

  def created_events
    result = Event.query_event_data(
        0,
        current_user.id,
        false,
        true,
        params[:offset]).as_json
    result.each do |item|
      author_id = item.delete "author_id"
      item[:time_to_event_text] = get_starts_in_text(item['start_time'])
      item[:is_popular] = if rand < 0.5 then true else false end
      item[:is_author_event] = current_user.id == author_id
      item['is_attending'] = item['is_attending'] == 1
    end

    render :json => result.to_json
  end
end
