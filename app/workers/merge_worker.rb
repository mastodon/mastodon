# frozen_string_literal: true

class MergeWorker
  include Sidekiq::Worker
  include Redisable

  def perform(from_account_id, into_account_id)
    ApplicationRecord.connected_to(role: :primary) do
      @from_account = Account.find(from_account_id)
      @into_account = Account.find(into_account_id)
    end

    ApplicationRecord.connected_to(role: :read, prevent_writes: true) do
      FeedManager.instance.merge_into_home(@from_account, @into_account)
    end
  rescue ActiveRecord::RecordNotFound
    true
  ensure
    redis.del("account:#{into_account_id}:regeneration")
  end
end
