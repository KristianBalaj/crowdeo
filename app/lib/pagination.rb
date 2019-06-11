class Pagination
  attr_reader :pages_count, :current_page

  def initialize(pages_count, current_page, page_group_size, page_path)
    @pages_count = pages_count
    @current_page = current_page
    @page_group_size = page_group_size
    @page_path = page_path
  end

  def is_first_page?
    @current_page == 1
  end

  def is_last_page?
    @current_page == @pages_count
  end

  def get_page_path(id)
    @page_path.call(id)
  end

  def get_previous_page_path
    @page_path.call((@current_page - 1).clamp(1, @pages_count))
  end

  def get_next_page_path
    @page_path.call((@current_page + 1).clamp(1, @pages_count))
  end

  # returns an array of ranges that should be displayed in pagination
  def calculate_page_ranges_arr
    result = []

    current_page_range = (@current_page - @page_group_size)..(@current_page + @page_group_size)
    start_range = 1..(@page_group_size)
    end_range = (@pages_count - @page_group_size + 1)..@pages_count

    if range_connected?(start_range, current_page_range)
      if range_connected?(current_page_range, end_range)
        result.push(1..@pages_count)
      else
        result.push(1..(@current_page + @page_group_size))
        result.push(end_range)
      end
    else
      if range_connected?(current_page_range, end_range)
        result.push(start_range)
        result.push((@current_page - @page_group_size)..@pages_count)
      else
        result.push(start_range)
        result.push(current_page_range)
        result.push(end_range)
      end
    end
  end

  private

  def range_connected?(range1, range2)
    is_connection = range1.first - 1 <= range2.last && range1.last + 1 >= range2.first
    is_connection || range1.first <= range2.last && range1.last >= range2.first
  end

end