require "test_helper"

class UserPolicyTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin_user)
    @user = users(:damian_user)
    @other_user = users(:nico_user)
  end

  test "admin is authorized for index, show, edit, update, destroy and toggle_admin" do
    policy = UserPolicy.new(@admin, @other_user)
    assert policy.index?
    assert policy.show?
    assert policy.edit?
    assert policy.update?
    assert policy.destroy?
    assert policy.toggle_admin?
  end

  test "regular user is not authorized for admin user policy actions" do
    policy = UserPolicy.new(@user, @other_user)
    assert_not policy.index?
    assert_not policy.show?
    assert_not policy.edit?
    assert_not policy.update?
    assert_not policy.destroy?
    assert_not policy.toggle_admin?
  end

  test "nil/guest user is not authorized" do
    policy = UserPolicy.new(nil, @other_user)
    assert_not policy.index?
    assert_not policy.update?
    assert_not policy.destroy?
  end
end
