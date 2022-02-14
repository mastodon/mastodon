# frozen_string_literal: true

class AccountWarningPolicy < ApplicationPolicy
  def show?
    target? || staff?
  end

  def appeal?
    target?
  end

  private

  def target?
    record.target_account_id == current_account&.id
  end
end
