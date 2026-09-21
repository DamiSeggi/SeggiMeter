require "test_helper"

class MultiUserFlowTest < ActionDispatch::IntegrationTest
  test "end to end user flow: auto-registration, lobby interaction, word submission limit, and profile" do
    # 1. Auto-registration on login
    post login_url, params: { name: "charlie", password: "mypassword123" }
    assert_redirected_to lobbies_url
    follow_redirect!
    assert_response :success
    assert_select ".logged-in-user", text: /charlie/

    charlie = User.find_by(name: "charlie")
    assert_not_nil charlie
    assert_not charlie.admin?

    # 2. View active lobby
    lobby = lobbies(:active_lobby)
    get lobby_url(lobby)
    assert_response :success
    assert_select ".submission-counter-badge", text: /0\/3/

    # 3. Submit 3 words
    [ "Innovation", "Agility", "Design" ].each_with_index do |word, idx|
      post lobby_submissions_url(lobby), params: { word: word }
      assert_redirected_to lobby_url(lobby)
      follow_redirect!
      assert_select ".submission-counter-badge", text: /#{idx + 1}\/3/
    end

    # 4. Attempt 4th submission - should be blocked by transaction
    assert_no_difference "Submission.count" do
      post lobby_submissions_url(lobby), params: { word: "OverflowWord" }
    end
    assert_redirected_to lobby_url(lobby)
    follow_redirect!
    assert_select ".flash-alert", text: /Limit reached/

    # 5. Profile password update
    get profile_url
    assert_select ".profile-value", text: "charlie"

    patch profile_url, params: { user: { password: "newpassword789", password_confirmation: "newpassword789" } }
    assert_redirected_to profile_url
    follow_redirect!
    assert_select ".flash-notice", text: /Password successfully updated/

    # 6. Logout
    delete logout_url
    assert_redirected_to login_url
    follow_redirect!
    assert_response :success

    # 7. Relogin with new password
    post login_url, params: { name: "charlie", password: "newpassword789" }
    assert_redirected_to lobbies_url
  end

  test "transaction rollback when error occurs in submission block" do
    user = users(:regular_user)
    lobby = lobbies(:second_lobby)

    initial_submissions = Submission.count
    initial_logs = ActivityLog.count

    assert_raises RuntimeError do
      ActiveRecord::Base.transaction do
        lobby.submissions.create!(user: user, word: "ValidWord")
        ActivityLog.create!(user: user, action: "submitted_word")
        raise "Simulated failure inside transaction"
      end
    end

    # Both submission and activity log must be rolled back
    assert_equal initial_submissions, Submission.count
    assert_equal initial_logs, ActivityLog.count
  end

  test "admin can edit question and lock is released" do
    admin = users(:admin_user)
    log_in_as(admin, password: "admin123")
    lobby = lobbies(:active_lobby)

    # Acquire lock
    post lock_lobby_url(lobby)
    assert lobby.reload.locked?
    assert_equal admin.id, lobby.locked_by_id

    # Update question and verify lock is cleared
    patch lobby_url(lobby), params: { lobby: { title: "New Live Question!" } }
    assert_redirected_to lobby_url(lobby)
    assert_equal "New Live Question!", lobby.reload.title
    assert_not lobby.locked?
    assert_nil lobby.locked_by_id
  end
end
