module Admin
  class UsersController < ApplicationController
    before_action :require_admin
    before_action :set_user, only: [:destroy, :toggle_admin]

    def index
      @users = User.order(created_at: :asc)
    end

    def destroy
      if @user.id == current_user.id
        redirect_to admin_users_path, alert: "Du kannst deinen eigenen Account nicht löschen."
        return
      end

      user_name = @user.name
      @user.destroy!
      ActivityLog.create!(user: current_user, action: "user_deleted")
      redirect_to admin_users_path, notice: "Benutzer '#{user_name}' wurde gelöscht."
    end

    def toggle_admin
      if @user.id == current_user.id && @user.admin?
        redirect_to admin_users_path, alert: "Du kannst dir deine eigenen Admin-Rechte nicht selbst entziehen."
        return
      end

      new_role = !@user.admin?
      @user.update!(admin: new_role)
      action = new_role ? "admin_promoted" : "admin_demoted"
      ActivityLog.create!(user: current_user, action: action)

      status_text = new_role ? "Admin ernannt" : "Admin-Rechte entzogen"
      redirect_to admin_users_path, notice: "Benutzer '#{@user.name}' wurde als #{status_text}."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end
  end
end
