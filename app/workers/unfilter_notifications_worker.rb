# frozen_string_literal: true

class UnfilterNotificationsWorker
  include Sidekiq::Worker

  def perform(notification_request_id)
    @notification_request = NotificationRequest.find(notification_request_id)

    push_to_conversations!
    unfilter_notifications!
    remove_request!
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  def push_to_conversations!
    notifications_with_private_mentions.find_each { |notification| AccountConversation.add_status(@notification_request.account, notification.target_status) }
  end

  def unfilter_notifications!
    filtered_notifications.in_batches.update_all(filtered: false)
  end

  def remove_request!
    @notification_request.destroy!
  end

  def filtered_notifications
    Notification.where(account: @notification_request.account, from_account: @notification_request.from_account, filtered: true)
  end

  def notifications_with_private_mentions
    filtered_notifications.joins(mention: :status).merge(Status.where(visibility: :direct)).includes(mention: :status)
  end
end
