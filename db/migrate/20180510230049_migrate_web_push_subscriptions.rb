# frozen_string_literal: true

class MigrateWebPushSubscriptions < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    add_index :web_push_subscriptions, :user_id, algorithm: :concurrently
    add_index :web_push_subscriptions, :access_token_id, algorithm: :concurrently
  end

  def down
    remove_index :web_push_subscriptions, :user_id
    remove_index :web_push_subscriptions, :access_token_id
  end
end
