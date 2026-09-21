class Lobby < ApplicationRecord
  belongs_to :user
  belongs_to :locked_by, class_name: "User", optional: true
  has_many :submissions, dependent: :destroy

  validates :title, presence: true, length: { minimum: 3, maximum: 200 }

  after_update_commit :broadcast_title_update

  def locked?
    locked_by_id.present?
  end

  def locked_by?(other_user)
    locked? && locked_by_id == other_user&.id
  end

  def lock_for!(other_user)
    with_lock do
      return false if locked? && locked_by_id != other_user.id

      update!(locked_by: other_user)
      true
    end
  end

  def unlock!
    with_lock do
      update!(locked_by: nil)
    end
  end

  def word_frequencies
    raw_words = submissions.pluck(:word).map { |w| w.to_s.strip }.reject(&:blank?)
    counts = Hash.new(0)
    display_names = {}

    raw_words.each do |w|
      key = w.downcase
      counts[key] += 1
      display_names[key] ||= w
    end

    counts.map { |key, count| [ display_names[key], count ] }.to_h
  end

  private

  def broadcast_title_update
    broadcast_replace_to "lobby_#{id}",
                         target: "lobby_title_display",
                         partial: "lobbies/title_text",
                         locals: { lobby: self }
  end
end
