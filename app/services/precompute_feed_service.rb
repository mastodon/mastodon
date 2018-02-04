# frozen_string_literal: true

class PrecomputeFeedService < BaseService
  def call(account)
    FeedManager.instance.populate_feed(account)
    Redis.current.del("account:#{account.id}:regeneration")
  end
end
