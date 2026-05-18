# frozen_string_literal: true

class Admin::EmailSubscriptionsPurgeWorker
  include Sidekiq::Worker

  sidekiq_options lock: :until_executed, lock_ttl: 1.week.to_i

  def perform
    EmailSubscription.in_batches.delete_all
  end
end
