# frozen_string_literal: true

class InvitePolicy < ApplicationPolicy
  def index?
    role.can?(:manage_invites)
  end

  def create?
    role.can?(:invite_users) && (current_user.created_at <= InviteValidator::MIN_ACCOUNT_AGE.ago || unrestricted?)
  end

  def unrestricted?
    role.can?(:bypass_invite_limits)
  end

  def deactivate_all?
    role.can?(:manage_invites)
  end

  def destroy?
    owner? || role.can?(:manage_invites)
  end

  private

  def owner?
    record.user_id == current_user&.id
  end
end
