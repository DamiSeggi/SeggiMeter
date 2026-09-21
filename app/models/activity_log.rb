class ActivityLog < ApplicationRecord
  belongs_to :user

  validates :action, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
