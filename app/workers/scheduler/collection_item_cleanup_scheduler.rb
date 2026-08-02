# frozen_string_literal: true

class Scheduler::CollectionItemCleanupScheduler
  include Sidekiq::Worker

  RETENTION_PERIOD = 24.hours

  sidekiq_options retry: 0, lock: :until_executed, lock_ttl: 1.day.to_i

  def perform
    CollectionItem
      .where(state: [:rejected, :revoked])
      .where(updated_at: ...(RETENTION_PERIOD.ago))
      .destroy_all
  end
end
