# frozen_string_literal: true

class WebPushNotificationWorker
  include Sidekiq::Worker

  sidekiq_options backtrace: true

  def perform(recipient_id, notification_id)
    recipient = Account.find(recipient_id)
    notification = Notification.find(notification_id)

    sessions_with_subscriptions = recipient.user.session_activations.reject { |session| session.web_push_subscription.nil? }

    sessions_with_subscriptions.each do |session|
      begin
        session.web_push_subscription.push(notification)
      rescue Webpush::InvalidSubscription, Webpush::ExpiredSubscription
        # Subscription expiration is not currently implemented in any browser
        session.web_push_subscription.destroy!
        session.web_push_subscription = nil
        session.save!
      rescue Webpush::PayloadTooLarge => e
        Rails.logger.error(e)
      end
    end
  end
end
