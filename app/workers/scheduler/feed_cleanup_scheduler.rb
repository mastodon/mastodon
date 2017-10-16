# frozen_string_literal: true
require 'sidekiq-scheduler'

class Scheduler::FeedCleanupScheduler
  include Sidekiq::Worker

  def perform
    redis.pipelined do
      inactive_users.each do |account_id|
        redis.del(FeedManager.instance.key(:home, account_id))
        redis.del(FeedManager.instance.key(:home, account_id, 'reblogs'))
      end
    end
  end

  private

  def inactive_users
    @inactive_users ||= User.confirmed.inactive.pluck(:account_id)
  end

  def redis
    Redis.current
  end
end
