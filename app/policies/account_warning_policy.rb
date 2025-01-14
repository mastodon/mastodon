# frozen_string_literal: true

class AccountWarningPolicy < ApplicationPolicy
  def show?
    target? || role.can?(:manage_appeals)
  end

  def appeal?
    target? && record.appeal_eligible?
  end

  private

  def target?
    record.target_account_id == current_account&.id
  end
end
