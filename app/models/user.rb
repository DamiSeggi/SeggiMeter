class User < ApplicationRecord
  has_secure_password

  has_many :lobbies, dependent: :destroy
  has_many :submissions, dependent: :destroy
  has_many :activity_logs, dependent: :destroy
  has_many :locked_lobbies, class_name: "Lobby", foreign_key: "locked_by_id", dependent: :nullify

  validates :name, presence: true,
                   uniqueness: { case_sensitive: false },
                   length: { minimum: 2, maximum: 50 }
  validates :password, length: { minimum: 4 }, allow_nil: true

  def submissions_for(lobby)
    submissions.where(lobby_id: lobby.id)
  end

  def submission_count_for(lobby)
    submissions_for(lobby).count
  end

  def can_submit_to?(lobby)
    submission_count_for(lobby) < 3
  end
end
