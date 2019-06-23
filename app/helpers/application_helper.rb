module ApplicationHelper

  def full_title(page_title = '')
    base_title = 'Crowdeo'
    if page_title.empty?
      base_title
    else
      base_title + ' - ' + page_title
    end
  end

  def go_to_login
    flash[:danger] = "You need to login first."
    redirect_to login_path
  end

end
