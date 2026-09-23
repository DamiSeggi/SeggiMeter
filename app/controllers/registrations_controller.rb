class RegistrationsController < ApplicationController
  def new
    redirect_to lobbies_path if logged_in?
    @user = User.new
  end

  def create
    @user = User.new(registration_params)
    @user.admin = false

    if @user.save
      session[:user_id] = @user.id
      ActivityLog.create!(user: @user, action: "user_registered")
      redirect_to lobbies_path, notice: "Account successfully created! Welcome, #{@user.name}."
    else
      flash.now[:alert] = @user.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:name, :password, :password_confirmation)
  end
end
