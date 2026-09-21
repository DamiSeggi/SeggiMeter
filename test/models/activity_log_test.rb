require "test_helper"

class ActivityLogTest < ActiveSupport::TestCase
  test "valid activity log belongs to user and requires action" do
    log = ActivityLog.new(user: users(:regular_user), action: "submitted_word")
    assert log.valid?
  end

  test "action must be present" do
    log = ActivityLog.new(user: users(:regular_user), action: "")
    assert_not log.valid?
    assert log.errors[:action].present?
  end
end
