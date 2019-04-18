class EventCardData

  attr_reader :event_model, :attendants_count, :author_model

  def initialize(event_model, attendants_count, author_model, editable)
    @event_model = event_model
    @attendants_count = attendants_count
    @author_model = author_model
    @editable = editable
  end

  def editable?
    @editable
  end

end