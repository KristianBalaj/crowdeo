require 'test_helper'

class EventTest < ActiveSupport::TestCase

  def setup
    @event = Event.new(
        name: "Event 1",
        start_date: "2017-03-06",
        end_date: "2017-03-07")
  end

  test "should be valid" do
    assert true
  end

  test "name should be present" do
    @event.name = "   "
    assert_not @event.valid?
  end

  test "start date should be present" do
    @event.start_date = " "
    assert_not @event.valid?
  end

  test "end date should be present" do
    @event.end_date = " "
    assert_not @event.valid?
  end
end
