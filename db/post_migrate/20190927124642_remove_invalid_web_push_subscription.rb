# frozen_string_literal: true

class RemoveInvalidWebPushSubscription < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    invalid_web_push_subscriptions = Web::PushSubscription.where(endpoint: '')
                                                          .or(Web::PushSubscription.where(key_p256dh: ''))
                                                          .or(Web::PushSubscription.where(key_auth: ''))
                                                          .preload(:session_activation)
    invalid_web_push_subscriptions.find_each do |web_push_subscription|
      web_push_subscription.session_activation&.update!(web_push_subscription_id: nil)
      web_push_subscription.destroy!
    end
  end

  def down; end
end
