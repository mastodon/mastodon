# frozen_string_literal: true

class AddNotNullToAdminActionLogColumns < ActiveRecord::Migration[7.2]
  def up
    connection.execute(<<~SQL.squish)
      DELETE FROM admin_action_logs
      WHERE account_id IS NULL
    SQL

    safety_assured { change_column_null :admin_action_logs, :account_id, false }
  end

  def down
    safety_assured { change_column_null :admin_action_logs, :account_id, true }
  end
end
