require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    User.new(nick_name: "nick",
             email: "user@mail.com",
             password: "password",
             password_confirmation: "password",
             gender_id: 1).save()
  end

  test "failed login" do
    get login_path
    assert_template 'sessions/new'
    assert_select 'a[href=?]', login_path
    post login_path, params: { session: {
        email: "test@mail.com",
        password: ""
    }}
    assert_template 'sessions/new'
    assert_select 'a[href=?]', login_path
    assert_select 'div.alert.alert-danger'
    get home_path
    assert_select 'div.alert.alert-danger', 0
    assert_not is_logged_in?
  end

  test "successful login followed by logout" do
    get login_path
    assert_template 'sessions/new'
    assert_select 'a[href=?]', login_path
    post login_path, params: { session: {
        email: "user@mail.com",
        password: "password"
    }}
    follow_redirect!
    assert_template 'events/index'
    assert_select "a[href=?]", login_path, 0
    assert_select 'a[href=?]', logout_path
    assert is_logged_in?
    delete logout_path
    assert_redirected_to root_path
    follow_redirect!
    assert_not is_logged_in?
    assert_select 'a[href=?]', login_path
    assert_select 'a[href=?]', logout_path, 0
  end
end
