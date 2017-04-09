# frozen_string_literal: true

class PrecomputeFeedService < BaseService
  # Fill up a user's home/mentions feed from DB and return a subset
  # @param [Symbol] type :home or :mentions
  # @param [Account] account
  def call(_, account)
    redis.pipelined do
      Status.as_home_timeline(account).limit(FeedManager::MAX_ITEMS / 4).each do |status|
        next if status.direct_visibility? || FeedManager.instance.filter?(:home, status, account.id)
        redis.zadd(FeedManager.instance.key(:home, account.id), status.id, status.reblog? ? status.reblog_of_id : status.id)
      end
    end
  end

  private

  def redis
    Redis.current
  end
end
