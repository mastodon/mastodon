# frozen_string_literal: true

class BackupPolicy < ApplicationPolicy
  MIN_AGE = 6.days

  def create?
    user_signed_in? && eligible_for_backup?
  end

  private

  def eligible_for_backup?
    current_user
      .backups
      .where(created_at: MIN_AGE.ago..)
      .count
      .zero?
  end
end
