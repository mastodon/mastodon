# frozen_string_literal: true

class ValidateAddNotNullToWebPushSubscriptionAccessToken < ActiveRecord::Migration[8.0]
  def up
    connection.execute(<<~SQL.squish)
      DELETE FROM web_push_subscriptions
      WHERE access_token_id IS NULL
    SQL

    validate_check_constraint :web_push_subscriptions, name: 'web_push_subscriptions_access_token_id_null'
    change_column_null :web_push_subscriptions, :access_token_id, false
    remove_check_constraint :web_push_subscriptions, name: 'web_push_subscriptions_access_token_id_null'
  end

  def down
    add_check_constraint :web_push_subscriptions, 'access_token_id IS NOT NULL', name: 'web_push_subscriptions_access_token_id_null', validate: false
    change_column_null :web_push_subscriptions, :access_token_id, true
  end
end
