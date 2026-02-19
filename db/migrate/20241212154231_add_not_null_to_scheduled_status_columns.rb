# frozen_string_literal: true

class AddNotNullToScheduledStatusColumns < ActiveRecord::Migration[7.2]
  def up
    connection.execute(<<~SQL.squish)
      DELETE FROM scheduled_statuses
      WHERE account_id IS NULL
    SQL

    safety_assured { change_column_null :scheduled_statuses, :account_id, false }
  end

  def down
    safety_assured { change_column_null :scheduled_statuses, :account_id, true }
  end
end
