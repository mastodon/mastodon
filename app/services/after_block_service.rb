# frozen_string_literal: true

class AfterBlockService < BaseService
  def call(account, target_account)
    clear_home_feed(account, target_account)
    clear_notifications(account, target_account)
    clear_conversations(account, target_account)
  end

  private

  def clear_home_feed(account, target_account)
    FeedManager.instance.clear_from_timeline(account, target_account)
  end

  def clear_conversations(account, target_account)
    AccountConversation.where(account: account)
                       .where('? = ANY(participant_account_ids)', target_account.id)
                       .in_batches
                       .destroy_all
  end

  def clear_notifications(account, target_account)
    Notification.where(account: account)
                .joins(:follow)
                .where(activity_type: 'Follow', follows: { account_id: target_account.id })
                .delete_all

    Notification.where(account: account)
                .joins(mention: :status)
                .where(activity_type: 'Mention', statuses: { account_id: target_account.id })
                .delete_all

    Notification.where(account: account)
                .joins(:favourite)
                .where(activity_type: 'Favourite', favourites: { account_id: target_account.id })
                .delete_all

    Notification.where(account: account)
                .joins(:status)
                .where(activity_type: 'Status', statuses: { account_id: target_account.id })
                .delete_all
  end
end
