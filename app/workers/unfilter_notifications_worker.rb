# frozen_string_literal: true

class UnfilterNotificationsWorker
  include Sidekiq::Worker

  # Earlier versions of the feature passed a `notification_request` ID
  # If `to_account_id` is passed, the first argument is an account ID
  # TODO for after 4.3.0: drop the single-argument case
  def perform(notification_request_or_account_id, from_account_id = nil)
    if from_account_id.present?
      @notification_request = nil
      @from_account = Account.find(from_account_id)
      @recipient    = Account.find(notification_request_or_account_id)
    else
      @notification_request = NotificationRequest.find(notification_request_or_account_id)
      @from_account = @notification_request.from_account
      @recipient    = @notification_request.account
    end

    push_to_conversations!
    unfilter_notifications!
    remove_request!
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  def push_to_conversations!
    notifications_with_private_mentions.reorder(nil).find_each(order: :desc) { |notification| AccountConversation.add_status(@recipient, notification.target_status) }
  end

  def unfilter_notifications!
    filtered_notifications.in_batches.update_all(filtered: false)
  end

  def remove_request!
    @notification_request&.destroy!
  end

  def filtered_notifications
    Notification.where(account: @recipient, from_account: @from_account, filtered: true)
  end

  def notifications_with_private_mentions
    filtered_notifications.where(type: :mention).joins(mention: :status).merge(Status.where(visibility: :direct)).includes(mention: :status)
  end
end
