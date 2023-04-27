# frozen_string_literal: true

class RemoveRecordedChangesFromAdminActionLogs < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured { remove_column :admin_action_logs, :recorded_changes, :text }
  end
end
