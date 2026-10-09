# frozen_string_literal: true

class MultiMergeIntoOwnHomeWorker
  include Sidekiq::Worker
  include DatabaseHelper
  include Redisable

  sidekiq_options lock: :until_executed

  # merges and unmerges own posts and boosts into home feed
  def perform(account_id, old_post_settings, old_reblog_settings)
    @account = Account.find(account_id)

    FeedManager.instance.unmerge_from_own_home(@account, old_post_settings, old_reblog_settings)
    FeedManager.instance.merge_into_own_home(@account, old_post_settings, old_reblog_settings)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
