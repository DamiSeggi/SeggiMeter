class Submission < ApplicationRecord
  belongs_to :user
  belongs_to :lobby

  validates :word, presence: true, length: { minimum: 1, maximum: 30 }
  validate :submission_limit_per_lobby, on: :create

  after_create_commit -> {
    broadcast_replace_to "lobby_#{lobby_id}",
                         target: "word_cloud",
                         partial: "lobbies/word_cloud",
                         locals: { lobby: lobby.reload }
  }

  private

  def submission_limit_per_lobby
    if user && lobby && user.submissions.where(lobby_id: lobby.id).count >= 3
      errors.add(:base, "Maximal 3 Wörter pro Frage erlaubt")
    end
  end
end
