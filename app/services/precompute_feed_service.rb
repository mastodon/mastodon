# frozen_string_literal: true

class PrecomputeFeedService < BaseService
  include Redisable

  def call(account)
    FeedManager.instance.populate_home(account)
  ensure
    redis.del("account:#{account.id}:regeneration")
  end
end
