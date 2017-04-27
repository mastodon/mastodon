# frozen_string_literal: true

class AfterBlockService < BaseService
  def call(account, target_account)
    clear_timelines(account, target_account)
    clear_notifications(account, target_account)
  end

  private

  def clear_timelines(account, target_account)
    home_key = FeedManager.instance.key(:home, account.id)

    redis.pipelined do
      target_account.statuses.select('id').reorder(nil).find_each do |status|
        redis.zrem(home_key, status.id)
      end
    end
  end

  def clear_notifications(account, target_account)
    Notification.where(account: account).joins(:follow).where(activity_type: 'Follow', follows: { account_id: target_account.id }).delete_all
    Notification.where(account: account).joins(mention: :status).where(activity_type: 'Mention', statuses: { account_id: target_account.id }).delete_all
    Notification.where(account: account).joins(:favourite).where(activity_type: 'Favourite', favourites: { account_id: target_account.id }).delete_all
    Notification.where(account: account).joins(:status).where(activity_type: 'Status', statuses: { account_id: target_account.id }).delete_all
  end

  def redis
    Redis.current
  end
end
