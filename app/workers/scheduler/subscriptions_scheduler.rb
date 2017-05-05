# frozen_string_literal: true
require 'sidekiq-scheduler'

class Scheduler::SubscriptionsScheduler
  include Sidekiq::Worker

  def perform
    Rails.logger.debug 'Queueing PuSH re-subscriptions'

    expiring_accounts.pluck(:id) do |id|
      Pubsubhubbub::SubscribeWorker.perform_async(id)
    end
  end

  private

  def expiring_accounts
    Account.expiring(1.day.from_now).partitioned
  end
end
