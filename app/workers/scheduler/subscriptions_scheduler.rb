# frozen_string_literal: true
<<<<<<< HEAD

require 'sidekiq-scheduler'
require 'sidekiq-bulk'
=======
require 'sidekiq-scheduler'
>>>>>>> origin/osaka-master

class Scheduler::SubscriptionsScheduler
  include Sidekiq::Worker

  def perform
    logger.info 'Queueing PuSH re-subscriptions'

<<<<<<< HEAD
    Pubsubhubbub::SubscribeWorker.push_bulk(expiring_accounts.pluck(:id))
=======
    expiring_accounts.pluck(:id).each do |id|
      Pubsubhubbub::SubscribeWorker.perform_async(id)
    end
>>>>>>> origin/osaka-master
  end

  private

  def expiring_accounts
    Account.expiring(1.day.from_now).partitioned
  end
end
