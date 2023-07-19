# frozen_string_literal: true

class MergeWorker
  include Sidekiq::Worker
  include Redisable
  include DatabaseHelper

  def perform(from_account_id, into_account_id)
    with_primary do
      @from_account = Account.find(from_account_id)
      @into_account = Account.find(into_account_id)
    end

    with_read_replica do
      FeedManager.instance.merge_into_home(@from_account, @into_account)
    end
  rescue ActiveRecord::RecordNotFound
    true
  ensure
    redis.del("account:#{into_account_id}:regeneration")
  end
end
