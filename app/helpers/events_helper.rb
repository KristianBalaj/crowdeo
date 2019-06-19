include ActionView::Helpers::DateHelper

module EventsHelper
  def get_created_ago_text(time)
    "Created " + time_ago_in_words(time) + " ago"
  end
end
