require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest

  test "should get root" do
    get root_url
    assert_response :success
  end

  test "should get home" do
    get home_path
    assert_response :success
    assert_select "title", "Crowdeo - Home"
  end

  test "should get about" do
    get about_path
    assert_response :success
    assert_select "title", "Crowdeo - About"
  end

end
