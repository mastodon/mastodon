# frozen_string_literal: true

class Web::PushNotificationWorker
  include Sidekiq::Worker

  sidekiq_options backtrace: true

  def perform(subscription_id, notification_id)
    subscription = ::Web::PushSubscription.find(subscription_id)
    notification = Notification.find(notification_id)

    subscription.push(notification) unless notification.activity.nil?
  rescue Webpush::ResponseError => e
    subscription.destroy! if (400..499).cover?(e.response.code.to_i)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
