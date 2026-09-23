require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  test "unauthenticated user cannot access profile" do
    get profile_url
    assert_redirected_to login_url
  end

  test "authenticated user can view profile" do
    user = users(:damian_user)
    log_in_as(user)

    get profile_url
    assert_response :success
    assert_select ".profile-value", text: user.name
    assert_select "input[name='user[password]']"
  end

  test "user can update password" do
    user = users(:damian_user)
    log_in_as(user)

    assert_difference "ActivityLog.count", 1 do
      patch profile_url, params: {
        user: { password: "newpassword123", password_confirmation: "newpassword123" }
      }
    end

    assert_redirected_to profile_url
    assert_equal "Password successfully updated.", flash[:notice]
    assert_equal "password_changed", ActivityLog.last.action

    # Verify new password works
    assert user.reload.authenticate("newpassword123")
  end
end
