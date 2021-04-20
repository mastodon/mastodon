# frozen_string_literal: true

class PotentialFriendshipTracker
  EXPIRE_AFTER = 90.days.seconds
  MAX_ITEMS    = 80

  WEIGHTS = {
    reply: 1,
    favourite: 10,
    reblog: 20,
  }.freeze

  class << self
    include Redisable

    def record(account_id, target_account_id, action)
      return if account_id == target_account_id

      key    = "interactions:#{account_id}"
      weight = WEIGHTS[action]

      redis.zincrby(key, weight, target_account_id)
      redis.zremrangebyrank(key, 0, -MAX_ITEMS)
      redis.expire(key, EXPIRE_AFTER)
    end

    def remove(account_id, target_account_id)
      redis.zrem("interactions:#{account_id}", target_account_id)
    end

    def get(account, limit)
      account_ids = redis.zrevrange("interactions:#{account.id}", 0, limit)

      return [] if account_ids.empty? || limit < 1

      accounts = Account.searchable.where(id: account_ids).index_by(&:id)

      account_ids.map { |id| accounts[id.to_i] }.compact
    end
  end
end
