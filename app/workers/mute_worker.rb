# frozen_string_literal: true

class MuteWorker
  include Sidekiq::Worker
  include Redisable

  def perform(account_id, target_account_id)
    @account        = Account.find(account_id)
    @target_account = Account.find(target_account_id)

    clear_home_feed!
    notify_streaming!
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  def clear_home_feed!
    FeedManager.instance.clear_from_home(@account, @target_account)
  end

  def notify_streaming!
    redis.publish('system', Oj.dump(event: :mutes_changed, account: @account.id, target_account: @target_account.id))
  end
end
