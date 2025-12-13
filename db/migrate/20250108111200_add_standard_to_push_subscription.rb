# frozen_string_literal: true

class AddStandardToPushSubscription < ActiveRecord::Migration[8.0]
  def change
    add_column :web_push_subscriptions, :standard, :boolean, null: false, default: false
  end
end
