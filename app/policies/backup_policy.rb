# frozen_string_literal: true

class BackupPolicy < ApplicationPolicy
  MIN_AGE = 1.week

  def create?
    user_signed_in? && current_user.backups.where('created_at >= ?', MIN_AGE.ago).count.zero?
  end
end
