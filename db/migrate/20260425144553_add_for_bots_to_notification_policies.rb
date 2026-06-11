# frozen_string_literal: true

class AddForBotsToNotificationPolicies < ActiveRecord::Migration[8.1]
  def change
    add_column :notification_policies, :for_bots, :integer, default: 0, null: false
  end
end
