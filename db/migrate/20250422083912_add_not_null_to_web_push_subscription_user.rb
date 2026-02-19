# frozen_string_literal: true

class AddNotNullToWebPushSubscriptionUser < ActiveRecord::Migration[8.0]
  def change
    add_check_constraint :web_push_subscriptions, 'user_id IS NOT NULL', name: 'web_push_subscriptions_user_id_null', validate: false
  end
end
