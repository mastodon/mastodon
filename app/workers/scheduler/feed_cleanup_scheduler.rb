# frozen_string_literal: true
require 'sidekiq-scheduler'

class Scheduler::FeedCleanupScheduler
  include Sidekiq::Worker

  def perform
    logger.info 'Cleaning out home feeds of inactive users'

    redis.pipelined do
      inactive_users.pluck(:account_id).each do |account_id|
        redis.del(FeedManager.instance.key(:home, account_id))
      end
    end
  end

  private

  def inactive_users
    User.confirmed.inactive
  end

  def redis
    Redis.current
  end
end
