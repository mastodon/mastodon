# frozen_string_literal: true

class AccountWarningPolicy < ApplicationPolicy
  def show?
    target? || role.can?(:manage_appeals)
  end

  def appeal?
    target? && eligible_for_appeal?
  end

  private

  def eligible_for_appeal?
    record.created_at >= Appeal::MAX_STRIKE_AGE.ago
  end

  def target?
    record.target_account_id == current_account&.id
  end
end
