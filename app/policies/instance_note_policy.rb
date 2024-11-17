# frozen_string_literal: true

class InstanceNotePolicy < ApplicationPolicy
  def create?
    role.can?(:manage_federation)
  end

  def destroy?
    owner? || (role.can?(:manage_federation) && role.overrides?(record.account.user_role))
  end

  private

  def owner?
    record.account_id == current_account&.id
  end
end
