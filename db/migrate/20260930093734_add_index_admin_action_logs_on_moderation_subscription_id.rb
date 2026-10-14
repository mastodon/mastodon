# frozen_string_literal: true

class AddIndexAdminActionLogsOnModerationSubscriptionId < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :admin_action_logs, :moderation_subscription_id, where: 'moderation_subscription_id IS NOT NULL', algorithm: :concurrently
  end
end
