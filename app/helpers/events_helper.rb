include ActionView::Helpers::DateHelper

module EventsHelper
  def get_created_ago_text(time)
    "In " + distance_of_time_in_words(Time.now, time)
  end

  def get_full_dateTime(date, time)
    date.to_s + ' ' + time.strftime('%H') + ':' + time.strftime('%M') + ':' + '00'
  end
end
