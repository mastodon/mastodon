# frozen_string_literal: true

class ValidateNotNullToPollAccountColumn < ActiveRecord::Migration[7.2]
  def up
    connection.execute(<<~SQL.squish)
      DELETE FROM polls
      WHERE account_id IS NULL
    SQL

    validate_check_constraint :polls, name: 'polls_account_id_null'
    change_column_null :polls, :account_id, false
    remove_check_constraint :polls, name: 'polls_account_id_null'
  end

  def down
    add_check_constraint :polls, 'account_id IS NOT NULL', name: 'polls_account_id_null', validate: false
    change_column_null :polls, :account_id, true
  end
end
