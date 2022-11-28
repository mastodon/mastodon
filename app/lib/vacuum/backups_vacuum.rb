# frozen_string_literal: true

module Vacuum
  class BackupsVacuum < Vacuum::RetentionPeriod
    def perform
      vacuum_expired_backups! if @retention_period.present?
    end

    private

    def vacuum_expired_backups!
      backups_past_retention_period.in_batches(&:destroy_all)
    end

    def backups_past_retention_period
      Backup.unscoped.where(created_at: ...@retention_period.ago)
    end
  end
end
