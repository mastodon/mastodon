# frozen_string_literal: true

class Web::PushNotificationWorker
  include Sidekiq::Worker

  sidekiq_options backtrace: true

  def perform(subscription_id, notification_id)
    subscription = ::Web::PushSubscription.find(subscription_id)
    notification = Notification.find(notification_id)

    subscription.push(notification) unless notification.activity.nil?
  rescue Webpush::InvalidSubscription, Webpush::ExpiredSubscription
    subscription.destroy!
  rescue ActiveRecord::RecordNotFound
    true
  end
end
