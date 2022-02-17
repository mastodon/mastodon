# frozen_string_literal: true

class AccountWarningPolicy < ApplicationPolicy
  def show?
    target? || staff?
  end

  def appeal?
    target? && record.created_at >= Appeal::MAX_STRIKE_AGE.ago
  end

  private

  def target?
    record.target_account_id == current_account&.id
  end
end
