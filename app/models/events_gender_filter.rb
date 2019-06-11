class EventsGenderFilter < ApplicationRecord
  belongs_to :gender
  belongs_to :event
end
