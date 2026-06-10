# frozen_string_literal: true

class AddActionLogsDataChanges < ActiveRecord::Migration[8.1]
  def change
    add_column :admin_action_logs, :tag_changes, :jsonb, null: true, default: nil
  end
end
