require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user with name and password" do
    user = User.new(name: "newuser", password: "111111111111")
    assert user.valid?
    assert_not user.admin?
  end

  test "name must be present" do
    user = User.new(name: "", password: "111111111111")
    assert_not user.valid?
    assert user.errors[:name].present?
  end

  test "password must be at least 12 characters" do
    user = User.new(name: "shortpass", password: "shortpass12") # 11 chars
    assert_not user.valid?
    assert user.errors[:password].present?
  end

  test "name must be unique case-insensitively" do
    existing = users(:regular_user)
    user = User.new(name: existing.name.upcase, password: "111111111111")
    assert_not user.valid?
    assert_includes user.errors[:name], "has already been taken"
  end

  test "can_submit_to? returns true when under limit and false when 3 submissions reached" do
    user = users(:regular_user)
    lobby = lobbies(:active_lobby)

    # user already has 1 submission in fixtures
    assert_equal 1, user.submission_count_for(lobby)
    assert user.can_submit_to?(lobby)

    # add 2 more
    Submission.create!(user: user, lobby: lobby, word: "Word2")
    Submission.create!(user: user, lobby: lobby, word: "Word3")

    assert_equal 3, user.submission_count_for(lobby)
    assert_not user.can_submit_to?(lobby)
  end
end
