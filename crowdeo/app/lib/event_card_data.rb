class EventCardData

  attr_reader :event_name, :event_description, :event_id, :event_created_at, :author_nick, :attendants_count

  def initialize(event_name, event_description, event_id, event_created_at, attendants_count, author_nick, editable)
    @event_name = event_name
    @event_description = event_description
    @event_id = event_id
    @event_created_at = event_created_at
    @author_nick = author_nick
    @attendants_count = attendants_count
    @editable = editable
  end

  def editable?
    @editable
  end

end