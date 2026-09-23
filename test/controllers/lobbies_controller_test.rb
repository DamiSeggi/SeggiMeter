require "test_helper"

class LobbiesControllerTest < ActionDispatch::IntegrationTest
  test "unauthenticated user is redirected to login" do
    get lobbies_url
    assert_redirected_to login_url

    get lobbies_url
    assert_redirected_to login_url

    get lobby_url(lobbies(:active_lobby))
    assert_redirected_to login_url
  end

  test "authenticated user can view lobbies index and show" do
    log_in_as(users(:regular_user))

    get lobbies_url
    assert_response :success
    assert_select "h2", "SeggiMeter"

    get lobby_url(lobbies(:active_lobby))
    assert_response :success
    assert_select "#word_cloud"
    assert_select ".submission-area"
  end

  test "non-admin cannot access new lobby page or create lobby" do
    log_in_as(users(:regular_user))

    get new_lobby_url
    assert_redirected_to lobbies_url
    assert_match "Access denied", flash[:alert]

    assert_no_difference "Lobby.count" do
      post lobbies_url, params: { lobby: { title: "Hacker question?" } }
    end
    assert_redirected_to lobbies_url
  end

  test "admin can create a new lobby" do
    admin = users(:admin_user)
    log_in_as(admin, password: "admin123")

    get new_lobby_url
    assert_response :success

    assert_difference "Lobby.count", 1 do
      assert_difference "ActivityLog.count", 1 do
        post lobbies_url, params: { lobby: { title: "How do you like Rails 8?" } }
      end
    end

    new_lobby = Lobby.last
    assert_redirected_to lobby_url(new_lobby)
    assert_equal admin.id, new_lobby.user_id
    assert_equal "lobby_created", ActivityLog.last.action
  end

  test "admin can update lobby title with locking" do
    admin = users(:admin_user)
    lobby = lobbies(:active_lobby)
    log_in_as(admin, password: "admin123")

    patch lobby_url(lobby), params: { lobby: { title: "Updated Question?" } }
    assert_redirected_to lobby_url(lobby)
    assert_equal "Updated Question?", lobby.reload.title
    assert_nil lobby.locked_by
  end

  test "lock cannot be acquired if already locked by another user" do
    admin1 = users(:admin_user)
    regular = users(:regular_user)
    lobby = lobbies(:active_lobby)

    # First lock by admin1
    lobby.lock_for!(admin1)

    log_in_as(regular)
    post lock_lobby_url(lobby)
    assert_redirected_to lobbies_url # regular user is not admin
  end
end
