# frozen_string_literal: true

class BackupPolicy < ApplicationPolicy
  REQUEST_DAYS_LIMIT = 7

  def create?
    user_signed_in? && user_backups_after_limit.count.zero?
  end

  private

  def user_backups_after_limit
    current_user
      .backups
      .where(created_at: (REQUEST_DAYS_LIMIT - 1).days.ago..)
  end
end
