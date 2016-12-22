# frozen_string_literal: true

class BlockService < BaseService
  def call(account, target_account)
    return if account.id == target_account.id

    UnfollowService.new.call(account, target_account) if account.following?(target_account)
    UnfollowService.new.call(target_account, account) if target_account.following?(account)

    account.block!(target_account)

    clear_timelines(account, target_account)
    clear_notifications(account, target_account)
  end

  private

  def clear_timelines(account, target_account)
    mentions_key = FeedManager.instance.key(:mentions, account.id)
    home_key     = FeedManager.instance.key(:home, account.id)

    target_account.statuses.select('id').find_each do |status|
      redis.zrem(mentions_key, status.id)
      redis.zrem(home_key, status.id)
    end
  end

  def clear_notifications(account, target_account)
    Notification.where(account: account).joins(:follow).where(activity_type: 'Follow', follows: { account_id: target_account.id }).destroy_all
    Notification.where(account: account).joins(mention: :status).where(activity_type: 'Mention', statuses: { account_id: target_account.id }).destroy_all
    Notification.where(account: account).joins(:favourite).where(activity_type: 'Favourite', favourites: { account_id: target_account.id }).destroy_all
    Notification.where(account: account).joins(:status).where(activity_type: 'Status', statuses: { account_id: target_account.id }).destroy_all
  end

  def redis
    Redis.current
  end
end
