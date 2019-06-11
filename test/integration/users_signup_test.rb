require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: {
          nick_name: "",
          email: "user@invalid",
          password: "smth",
          password_confirmation: "smth_else"
      }}
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.alert.alert-danger'
  end

  test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: {
          nick_name: "nick",
          email: "user@mail.com",
          password: "password",
          password_confirmation: "password"
      }}
    end
    follow_redirect!
    assert_template 'events/index'
    assert_select 'div.alert.alert-success'
    assert is_logged_in?
  end

end
