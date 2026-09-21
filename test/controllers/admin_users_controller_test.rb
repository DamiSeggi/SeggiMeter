require "test_helper"

class AdminUsersControllerTest < ActionDispatch::IntegrationTest
  test "unauthenticated user cannot access admin users" do
    get admin_users_url
    assert_redirected_to login_url
  end

  test "regular non-admin user cannot access admin users" do
    log_in_as(users(:regular_user))
    get admin_users_url

    assert_redirected_to lobbies_url
    assert_match "Zugriff verweigert", flash[:alert]
  end

  test "admin can view admin users page" do
    admin = users(:admin_user)
    log_in_as(admin, password: "admin123")

    get admin_users_url
    assert_response :success
    assert_select "h1", text: /Benutzerverwaltung/
    assert_select "table.admin-users-table"
  end

  test "admin can toggle admin status for another user" do
    admin = users(:admin_user)
    target = users(:regular_user)
    log_in_as(admin, password: "admin123")

    assert_not target.admin?

    # Promote to admin
    assert_difference "ActivityLog.count", 1 do
      patch toggle_admin_admin_user_url(target)
    end
    assert_redirected_to admin_users_url
    assert target.reload.admin?
    assert_equal "admin_promoted", ActivityLog.last.action

    # Demote from admin
    assert_difference "ActivityLog.count", 1 do
      patch toggle_admin_admin_user_url(target)
    end
    assert_redirected_to admin_users_url
    assert_not target.reload.admin?
    assert_equal "admin_demoted", ActivityLog.last.action
  end

  test "admin cannot demote self" do
    admin = users(:admin_user)
    log_in_as(admin, password: "admin123")

    patch toggle_admin_admin_user_url(admin)
    assert_redirected_to admin_users_url
    assert_match "nicht selbst entziehen", flash[:alert]
    assert admin.reload.admin?
  end

  test "admin can delete another user" do
    admin = users(:admin_user)
    target = users(:second_user)
    log_in_as(admin, password: "admin123")

    assert_difference "User.count", -1 do
      assert_difference "ActivityLog.count", 1 do
        delete admin_user_url(target)
      end
    end

    assert_redirected_to admin_users_url
    assert_equal "user_deleted", ActivityLog.last.action
    assert_nil User.find_by(id: target.id)
  end

  test "admin cannot delete self" do
    admin = users(:admin_user)
    log_in_as(admin, password: "admin123")

    assert_no_difference "User.count" do
      delete admin_user_url(admin)
    end

    assert_redirected_to admin_users_url
    assert_match "eigenen Account nicht löschen", flash[:alert]
  end
end
