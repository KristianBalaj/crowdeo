class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "Account created successfully."
      redirect_to all_events_path
    else
      render 'new'
    end
  end

  private

  def user_params
    params.require(:user).permit(
        :nick_name,
        :birth_date,
        :email,
        :password,
        :password_confirmation,
        :calendar_sync?,
        :gender_id)
  end

end
