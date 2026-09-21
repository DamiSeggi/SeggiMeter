class ApplicationController < ActionController::Base
  allow_browser versions: :modern, unless: -> { Rails.env.test? }
  stale_when_importmap_changes

  helper_method :current_user, :logged_in?, :admin?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def admin?
    logged_in? && current_user.admin?
  end

  def require_login
    unless logged_in?
      flash[:alert] = "Please log in first."
      redirect_to login_path
    end
  end

  def require_admin
    require_login
    return if performed?

    unless admin?
      flash[:alert] = "Access denied. Only administrators have access to this area."
      redirect_to lobbies_path
    end
  end
end
