# frozen_string_literal: true

class PrecomputeFeedService < BaseService
  include Redisable

  def call(account)
    FeedManager.instance.populate_home(account)

    account.owned_lists.each do |list|
      FeedManager.instance.populate_list(list)
    end
  ensure
    redis.del("account:#{account.id}:regeneration")
  end
end
