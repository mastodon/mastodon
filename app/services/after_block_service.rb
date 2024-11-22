# frozen_string_literal: true

class AfterBlockService < BaseService
  def call(account, target_account)
    @account        = account
    @target_account = target_account

    clear_home_feed!
    clear_list_feeds!
    clear_notification_requests!
    clear_notifications!
    clear_conversations!
  end

  private

  def clear_home_feed!
    FeedManager.instance.clear_from_home(@account, @target_account)
  end

  def clear_list_feeds!
    FeedManager.instance.clear_from_lists(@account, @target_account)
  end

  def clear_conversations!
    AccountConversation.where(account: @account).where('? = ANY(participant_account_ids)', @target_account.id).in_batches.destroy_all
  end

  def clear_notifications!
    Notification.where(account: @account).where(from_account: @target_account).in_batches.delete_all
  end

  def clear_notification_requests!
    NotificationRequest.where(account: @account, from_account: @target_account).destroy_all
  end
end
