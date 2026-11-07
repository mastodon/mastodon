# frozen_string_literal: true

class AddServerKeyToWebPushSubscriptions < ActiveRecord::Migration[8.1]
  def change
    add_column :web_push_subscriptions, :server_key, :string
  end
end
