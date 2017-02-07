# frozen_string_literal: true

class PushNotificationWorker
  include Sidekiq::Worker

  def perform(notification_id)
    SendPushNotificationService.new.call(Notification.find(notification_id))
  rescue ActiveRecord::RecordNotFound
    true
  end
end
