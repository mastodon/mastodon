# frozen_string_literal: true

class Scheduler::FeedCleanupScheduler
  include Sidekiq::Worker
  include Redisable

  sidekiq_options lock: :until_executed, retry: 0

  def perform
    clean_home_feeds!
    clean_list_feeds!
  end

  private

  def clean_home_feeds!
    clean_feeds!(inactive_account_ids, :home)
  end

  def clean_list_feeds!
    clean_feeds!(inactive_list_ids, :list)
  end

  def clean_feeds!(ids, type)
    reblogged_id_sets = {}

    redis.pipelined do
      ids.each do |feed_id|
        redis.del(feed_manager.key(type, feed_id))
        reblog_key = feed_manager.key(type, feed_id, 'reblogs')
        # We collect a future for this: we don't block while getting
        # it, but we can iterate over it later.
        reblogged_id_sets[feed_id] = redis.zrange(reblog_key, 0, -1)
        redis.del(reblog_key)
      end
    end

    # Remove all of the reblog tracking keys we just removed the
    # references to.
    redis.pipelined do
      reblogged_id_sets.each do |feed_id, future|
        future.value.each do |reblogged_id|
          reblog_set_key = feed_manager.key(type, feed_id, "reblogs:#{reblogged_id}")
          redis.del(reblog_set_key)
        end
      end
    end
  end

  def inactive_account_ids
    @inactive_account_ids ||= User.confirmed.inactive.pluck(:account_id)
  end

  def inactive_list_ids
    List.where(account_id: inactive_account_ids).pluck(:id)
  end

  def feed_manager
    FeedManager.instance
  end
end
