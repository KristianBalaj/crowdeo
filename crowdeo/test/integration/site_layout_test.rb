require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  test "home layout links" do
    get home_path
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", signup_path
  end
end
