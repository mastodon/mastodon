# frozen_string_literal: true

class MultiMergeIntoOwnHomeWorker
  include Sidekiq::Worker
  include DatabaseHelper
  include Redisable

  sidekiq_options lock: :until_executed

  # merges and unmerges own posts and boosts into home feed
  def perform(account_id, display_post, display_reblog)
    @account = Account.find(account_id)

    if display_post == true
      FeedManager.instance.merge_into_own_home(@account, :post)
    elsif display_post == false
      FeedManager.instance.unmerge_from_own_home(@account, :post)
    end

    if display_reblog == true
      FeedManager.instance.merge_into_own_home(@account, :reblog)
    elsif display_reblog == false
      FeedManager.instance.unmerge_from_own_home(@account, :reblog)
    end
  rescue ActiveRecord::RecordNotFound
    true
  end
end
