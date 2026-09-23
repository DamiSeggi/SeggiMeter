class UserPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin?
  end

  def edit?
    update?
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end

  def toggle_admin?
    admin?
  end

  private

  def admin?
    user.present? && user.admin?
  end
end
