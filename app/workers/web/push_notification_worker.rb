# frozen_string_literal: true

class Web::PushNotificationWorker
  include Sidekiq::Worker

  sidekiq_options backtrace: true, retry: 5

  def perform(subscription_id, notification_id)
    subscription = ::Web::PushSubscription.find(subscription_id)
    notification = Notification.find(notification_id)

    subscription.push(notification) unless notification.activity.nil?
  rescue Webpush::ResponseError => e
    code = e.response.code.to_i

    if (400..499).cover?(code) && ![408, 429].include?(code)
      subscription.destroy!
    else
      raise e
    end
  rescue ActiveRecord::RecordNotFound
    true
  end
end
