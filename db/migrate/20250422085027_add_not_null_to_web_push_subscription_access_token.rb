# frozen_string_literal: true

class AddNotNullToWebPushSubscriptionAccessToken < ActiveRecord::Migration[8.0]
  def change
    add_check_constraint :web_push_subscriptions, 'access_token_id IS NOT NULL', name: 'web_push_subscriptions_access_token_id_null', validate: false
  end
end
