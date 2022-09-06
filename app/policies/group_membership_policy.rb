# frozen_string_literal: true

class GroupMembershipPolicy < ApplicationPolicy
  def revoke?
    group_staff? && rank_from_role(record.role) < rank_from_role(group_role)
  end

  private

  def rank_from_role(role)
    %i(user moderator admin).index(role.to_sym)
  end

  def group_role
    record.group.memberships.find_by(account_id: current_account&.id)&.role
  end

  def group_staff?
    record.group.memberships.where(account_id: current_account&.id, role: [:moderator, :admin]).exists?
  end
end
