require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(
        nick_name: "user1",
        email: "user1@smth.com",
        password: "password",
        password_confirmation: "password")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "nick name should be present" do
    @user.nick_name = "     "
    assert_not @user.valid?
  end

  test "nick name should not contain whitespace" do
    @user.nick_name = "hello me"
    assert_not @user.valid?
    @user.nick_name = "hello  me"
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = "    "
    assert_not @user.valid?
  end

  test "nick name should not be too long" do
    @user.nick_name = "a" * 26
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 250 + "@a.com"
    assert_not @user.valid?
  end

  test "emails should be only the valid ones" do
    invalid_mails = %w(yes@smth,com no@yes@.com @yes.com yes.com yes@no.)
    invalid_mails.each do |mail|
      @user.email = mail
      assert_not @user.valid?
    end
  end

  test "emails should be unique" do
    duplicate_user = @user.dup
    duplicate_user.nick_name = "user2"
    duplicate_user.email = duplicate_user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "nick names should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = "user2@smth.com"
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email addresses should be saved as lower-case" do
    email = "YeS@no.COM"
    @user.email = email
    @user.save
    assert_equal email.downcase, @user.email
  end

  test "password should be non blank" do
    @user.password = @user.password_confirmation = "    "
    assert_not @user.valid?
  end

  test "password should have minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end
end
