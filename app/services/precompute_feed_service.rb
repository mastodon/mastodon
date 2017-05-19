# frozen_string_literal: true

class PrecomputeFeedService < BaseService
  def call(account)
    redis.pipelined do
      # NOTE: Added `id desc, account_id desc` to `ORDER BY` section to optimize query.
      Status.as_home_timeline(account).order(account_id: :desc).limit(FeedManager::MAX_ITEMS / 4).each do |status|
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
