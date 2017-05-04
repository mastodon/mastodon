# frozen_string_literal: true
require 'sidekiq-scheduler'

class Scheduler::SubscriptionsScheduler
  include Sidekiq::Worker

  def perform
    Account.expiring(1.day.from_now).partitioned.pluck(:id) do |id|
      Pubsubhubbub::SubscribeWorker.perform_async(id)
    end
  end
end
