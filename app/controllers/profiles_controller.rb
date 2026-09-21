class ProfilesController < ApplicationController
  before_action :require_login

  def show
    @user = current_user
  end

  def update
    @user = current_user
    new_password = params.dig(:user, :password)

    if new_password.blank?
      flash.now[:alert] = "Please enter a new password."
      render :show, status: :unprocessable_entity
      return
    end

    if @user.update(password_params)
      ActivityLog.create!(user: @user, action: "password_changed")
      redirect_to profile_path, notice: "Password successfully updated."
    else
      flash.now[:alert] = @user.errors.full_messages.to_sentence
      render :show, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
