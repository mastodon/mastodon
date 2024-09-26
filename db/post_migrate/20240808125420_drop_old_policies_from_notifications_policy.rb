# frozen_string_literal: true

class DropOldPoliciesFromNotificationsPolicy < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      remove_column :notification_policies, :filter_not_following, :boolean, default: false, null: false
      remove_column :notification_policies, :filter_not_followers, :boolean, default: false, null: false
      remove_column :notification_policies, :filter_new_accounts, :boolean, default: false, null: false
      remove_column :notification_policies, :filter_private_mentions, :boolean, default: true, null: false
    end
  end
end
