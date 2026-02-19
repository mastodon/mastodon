# frozen_string_literal: true

class AddNotNullToAccountDeletionRequestColumns < ActiveRecord::Migration[7.2]
  def up
    connection.execute(<<~SQL.squish)
      DELETE FROM account_deletion_requests
      WHERE account_id IS NULL
    SQL

    safety_assured { change_column_null :account_deletion_requests, :account_id, false }
  end

  def down
    safety_assured { change_column_null :account_deletion_requests, :account_id, true }
  end
end
