# frozen_string_literal: true

class AddLogChangesToActionLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :admin_action_logs, :log_changes, :jsonb, null: true, default: nil
  end
end
