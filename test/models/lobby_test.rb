require "test_helper"

class LobbyTest < ActiveSupport::TestCase
  test "valid lobby belongs to user" do
    lobby = Lobby.new(title: "New Question?", user: users(:admin_user))
    assert lobby.valid?
    assert_not lobby.locked?
  end

  test "title must be present" do
    lobby = Lobby.new(title: "", user: users(:admin_user))
    assert_not lobby.valid?
    assert lobby.errors[:title].present?
  end

  test "word_frequencies aggregates and counts submissions correctly" do
    lobby = lobbies(:active_lobby)
    user = users(:damian_user)

    Submission.create!(user: user, lobby: lobby, word: "Ruby")
    Submission.create!(user: user, lobby: lobby, word: "ruby")

    freqs = lobby.word_frequencies
    assert_equal 3, freqs["Ruby"] # 1 from fixture + 2 new
  end

  test "pessimistic locking behavior" do
    lobby = lobbies(:active_lobby)
    admin1 = users(:admin_user)
    user = users(:damian_user)

    assert lobby.lock_for!(admin1)
    assert lobby.locked?
    assert lobby.locked_by?(admin1)

    # Another user cannot acquire lock
    assert_not lobby.lock_for!(user)

    # Unlock
    lobby.unlock!
    assert_not lobby.locked?
    assert_nil lobby.locked_by
  end
end
