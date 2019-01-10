# frozen_string_literal: true

class Scheduler::SubscriptionsScheduler
  include Sidekiq::Worker

  sidekiq_options unique: :until_executed, retry: 0

  def perform
    Pubsubhubbub::SubscribeWorker.push_bulk(expiring_accounts.pluck(:id))
  end

  private

  def expiring_accounts
    Account.expiring(1.day.from_now).partitioned
  end
end
