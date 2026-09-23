require "test_helper"

class SubmissionTest < ActiveSupport::TestCase
  test "valid submission belongs to user and lobby" do
    submission = Submission.new(user: users(:second_user), lobby: lobbies(:second_lobby), word: "Framework")
    assert submission.valid?
  end

  test "word cannot be blank" do
    submission = Submission.new(user: users(:second_user), lobby: lobbies(:second_lobby), word: "")
    assert_not submission.valid?
  end

  test "cannot submit more than 3 words per lobby" do
    user = users(:second_user)
    lobby = lobbies(:second_lobby)

    3.times do |i|
      Submission.create!(user: user, lobby: lobby, word: "Word#{i}")
    end

    fourth = Submission.new(user: user, lobby: lobby, word: "Word4")
    assert_not fourth.valid?
    assert_includes fourth.errors[:base], "Maximum 3 words per lobby allowed"
  end
end
