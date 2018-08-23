# frozen_string_literal: true

class Scheduler::SubscriptionsCleanupScheduler
  include Sidekiq::Worker

  sidekiq_options unique: :until_executed

  def perform
    Subscription.expired.in_batches.delete_all
  end
end
