# frozen_string_literal: true

class AddModerationSubscriptionIdToAdminActionLogs < ActiveRecord::Migration[8.1]
  def change
    # This does not have a foreign key because we want to keep that information when the subscription is deleted
    add_column :admin_action_logs, :moderation_subscription_id, :bigint, null: true
  end
end
