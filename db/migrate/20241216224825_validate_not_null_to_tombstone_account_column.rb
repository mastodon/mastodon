# frozen_string_literal: true

class ValidateNotNullToTombstoneAccountColumn < ActiveRecord::Migration[7.2]
  def up
    connection.execute(<<~SQL.squish)
      DELETE FROM tombstones
      WHERE account_id IS NULL
    SQL

    validate_check_constraint :tombstones, name: 'tombstones_account_id_null'
    change_column_null :tombstones, :account_id, false
    remove_check_constraint :tombstones, name: 'tombstones_account_id_null'
  end

  def down
    add_check_constraint :tombstones, 'account_id IS NOT NULL', name: 'tombstones_account_id_null', validate: false
    change_column_null :tombstones, :account_id, true
  end
end
