require "test_helper"

class SubmissionsControllerTest < ActionDispatch::IntegrationTest
  test "unauthenticated user cannot submit words" do
    lobby = lobbies(:active_lobby)
    assert_no_difference "Submission.count" do
      post lobby_submissions_url(lobby), params: { word: "Testing" }
    end
    assert_redirected_to login_url
  end

  test "user can submit word and it increments activity log" do
    user = users(:regular_user)
    lobby = lobbies(:active_lobby)
    log_in_as(user)

    assert_difference "Submission.count", 1 do
      assert_difference "ActivityLog.count", 1 do
        post lobby_submissions_url(lobby), params: { word: "Hotwire" }
      end
    end

    assert_redirected_to lobby_url(lobby)
    assert_equal "submitted_word", ActivityLog.last.action
  end

  test "atomic transaction enforces 3 submissions limit" do
    user = users(:second_user) # starts with 1 submission in fixtures
    lobby = lobbies(:active_lobby)
    log_in_as(user)

    # Submission 2
    post lobby_submissions_url(lobby), params: { word: "Turbo" }
    assert_response :redirect

    # Submission 3
    post lobby_submissions_url(lobby), params: { word: "Stimulus" }
    assert_response :redirect

    assert_equal 3, user.submission_count_for(lobby)

    # 4th submission should fail atomically without creating record
    assert_no_difference "Submission.count" do
      assert_no_difference "ActivityLog.count" do
        post lobby_submissions_url(lobby), params: { word: "ShouldFail" }
      end
    end

    assert_redirected_to lobby_url(lobby)
    assert_match "Limit erreicht", flash[:alert]
  end

  test "submitting blank word is rejected" do
    user = users(:regular_user)
    lobby = lobbies(:active_lobby)
    log_in_as(user)

    assert_no_difference "Submission.count" do
      post lobby_submissions_url(lobby), params: { word: "   " }
    end

    assert_redirected_to lobby_url(lobby)
    assert_match "Bitte ein Wort eingeben", flash[:alert]
  end
end
