class SessionsController < ApplicationController
  def new
    redirect_to lobbies_path if logged_in?
  end

  def create
    name = params[:name].to_s.strip
    password = params[:password]

    if name.blank? || password.blank?
      flash.now[:alert] = "Please enter your username and password."
      render :new, status: :unprocessable_entity
      return
    end

    user = User.find_by("LOWER(name) = ?", name.downcase)

    if user
      if user.authenticate(password)
        session[:user_id] = user.id
        ActivityLog.create!(user: user, action: "user_logged_in")
        redirect_to lobbies_path, notice: "Welcome back, #{user.name}!"
      else
        flash.now[:alert] = "Invalid password for this user."
        render :new, status: :unprocessable_entity
      end
    else
      user = User.new(name: name, password: password, admin: false)
      if user.save
        session[:user_id] = user.id
        ActivityLog.create!(user: user, action: "user_registered")
        redirect_to lobbies_path, notice: "Account successfully created! Welcome, #{user.name}."
      else
        flash.now[:alert] = user.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end
  end

  def destroy
    ActivityLog.create!(user: current_user, action: "user_logged_out") if logged_in?
    session[:user_id] = nil
    redirect_to login_path, notice: "Successfully logged out."
  end
end
