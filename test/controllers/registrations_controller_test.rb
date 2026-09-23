require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get signup page" do
    get signup_url
    assert_response :success
    assert_select "input[name='user[name]']"
    assert_select "input[name='user[password]']"
    assert_select "input[name='user[password_confirmation]']"
  end

  test "user can register with valid parameters" do
    assert_difference "User.count", 1 do
      assert_difference "ActivityLog.count", 1 do
        post signup_url, params: {
          user: {
            name: "brandnewuser",
            password: "validpassword123",
            password_confirmation: "validpassword123"
          }
        }
      end
    end

    new_user = User.find_by(name: "brandnewuser")
    assert_not_nil new_user
    assert_not new_user.admin?
    assert_equal new_user.id, session[:user_id]
    assert_redirected_to lobbies_url
    assert_equal "user_registered", ActivityLog.last.action
  end

  test "registration fails when password is less than 12 characters" do
    assert_no_difference "User.count" do
      post signup_url, params: {
        user: {
          name: "shortpassworduser",
          password: "shortpass12",
          password_confirmation: "shortpass12"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_nil session[:user_id]
    assert_match "Password is too short", flash[:alert]
  end

  test "registration fails when username is duplicate" do
    existing = users(:damian_user)
    assert_no_difference "User.count" do
      post signup_url, params: {
        user: {
          name: existing.name.upcase,
          password: "validpassword123",
          password_confirmation: "validpassword123"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_match "Name has already been taken", flash[:alert]
  end
end
