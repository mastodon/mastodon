# frozen_string_literal: true

class AddRecordedChangesToActionLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :admin_action_logs, :recorded_changes, :jsonb, null: true, default: nil
  end
end
