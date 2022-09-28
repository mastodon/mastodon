# frozen_string_literal: true

class Vacuum::BackupsVacuum
  def initialize(retention_period)
    @retention_period = retention_period
  end

  def perform
    vacuum_expired_backups! if retention_period?
  end

  private

  def vacuum_expired_backups!
    backups_past_retention_period.in_batches.destroy_all
  end

  def backups_past_retention_period
    Backup.unscoped.where(Backup.arel_table[:created_at].lt(@retention_period.ago))
  end

  def retention_period?
    @retention_period.present?
  end
end
