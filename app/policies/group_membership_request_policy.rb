# frozen_string_literal: true

class GroupMembershipRequestPolicy < ApplicationPolicy
  def index?
    group_staff?
  end

  def accept?
    group_staff?
  end

  def reject?
    group_staff?
  end

  private

  def group_staff?
    record.group.memberships.where(account_id: current_account&.id, role: [:moderator, :admin]).exists?
  end
end
