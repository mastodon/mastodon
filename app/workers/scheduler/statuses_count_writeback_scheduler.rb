# frozen_string_literal: true
require 'sidekiq-scheduler'

class Scheduler::StatusesCountWritebackScheduler
  include Sidekiq::Worker

  def perform
    redis.sscan_each(Account::STATUSES_COUNT_UPDATED_CACHE_KEY) do |account_id|
      redis.srem(Account::STATUSES_COUNT_UPDATED_CACHE_KEY, account_id)
      StatusesCountWritebackWorker.perform_async(account_id)
    end
  end

  private

  def redis
    Redis.current
  end
end
