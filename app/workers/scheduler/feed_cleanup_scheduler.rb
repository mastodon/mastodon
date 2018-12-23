# frozen_string_literal: true
require 'sidekiq-scheduler'

class Scheduler::FeedCleanupScheduler
  include Sidekiq::Worker

  def perform
    reblogged_id_sets = {}
    feedmanager = FeedManager.instance

    redis.pipelined do
      inactive_user_ids.each do |account_id|
        redis.del(feedmanager.key(:home, account_id))
        reblog_key = feedmanager.key(:home, account_id, 'reblogs')
        # We collect a future for this: we don't block while getting
        # it, but we can iterate over it later.
        reblogged_id_sets[account_id] = redis.zrange(reblog_key, 0, -1)
        redis.del(reblog_key)
      end
    end

    # Remove all of the reblog tracking keys we just removed the
    # references to.
    redis.pipelined do
      reblogged_id_sets.each do |account_id, future|
        future.value.each do |reblogged_id|
          reblog_set_key = feedmanager.key(:home, account_id, "reblogs:#{reblogged_id}")
          redis.del(reblog_set_key)
        end
      end
    end
  end

  private

  def inactive_user_ids
    @inactive_user_ids ||= User.confirmed.inactive.pluck(:account_id)
  end

  def redis
    Redis.current
  end
end
