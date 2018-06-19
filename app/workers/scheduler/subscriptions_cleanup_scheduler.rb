# frozen_string_literal: true

class Scheduler::SubscriptionsCleanupScheduler
  include Sidekiq::Worker

  def perform
    Subscription.expired.in_batches.delete_all
  end
end
