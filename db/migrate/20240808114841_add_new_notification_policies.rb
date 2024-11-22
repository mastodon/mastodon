# frozen_string_literal: true

class AddNewNotificationPolicies < ActiveRecord::Migration[7.1]
  def change
    add_column :notification_policies, :for_not_following, :integer, default: 0, null: false
    add_column :notification_policies, :for_not_followers, :integer, default: 0, null: false
    add_column :notification_policies, :for_new_accounts, :integer, default: 0, null: false
    add_column :notification_policies, :for_private_mentions, :integer, default: 1, null: false
    add_column :notification_policies, :for_limited_accounts, :integer, default: 1, null: false
  end
end
