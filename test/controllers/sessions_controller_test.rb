require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get login page" do
    get login_url
    assert_response :success
    assert_select "input[name='name']"
    assert_select "input[name='password']"
    assert_select "input[type='submit'][value='Enter']"
  end

  test "existing user logs in with valid password" do
    user = users(:regular_user)

    assert_difference "ActivityLog.count", 1 do
      post login_url, params: { name: user.name, password: "password123" }
    end

    assert_redirected_to lobbies_url
    assert_equal user.id, session[:user_id]
    assert_equal "user_logged_in", ActivityLog.last.action
  end

  test "existing user fails to log in with invalid password" do
    user = users(:regular_user)
    post login_url, params: { name: user.name, password: "wrongpassword" }

    assert_response :unprocessable_entity
    assert_nil session[:user_id]
    assert_match "Ungültiges Passwort", flash[:alert]
  end

  test "non-existing user is auto-registered on login" do
    assert_difference "User.count", 1 do
      assert_difference "ActivityLog.count", 1 do
        post login_url, params: { name: "brandnewuser", password: "securepassword" }
      end
    end

    new_user = User.find_by(name: "brandnewuser")
    assert_not_nil new_user
    assert_not new_user.admin?
    assert_equal new_user.id, session[:user_id]
    assert_redirected_to lobbies_url
    assert_equal "user_registered", ActivityLog.last.action
  end

  test "user can log out" do
    user = users(:regular_user)
    log_in_as(user)

    delete logout_url
    assert_nil session[:user_id]
    assert_redirected_to login_url
  end
end
