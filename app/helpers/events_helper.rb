include ActionView::Helpers::DateHelper

module EventsHelper
  def get_starts_in_text(time)
    "In " + distance_of_time_in_words(Time.now.getutc, time)
  end

  def get_categories_only_arr
    Category.all.map {|c| [c.name, c.id]}
  end

  def get_categories_with_all_arr
    temp = get_categories_only_arr
    temp.unshift ['All', -1]
    return temp
  end

  def get_categories_with_none_arr
    temp = get_categories_only_arr
    temp.unshift ['None', -1]
    return temp
  end
end
