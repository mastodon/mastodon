# frozen_string_literal: true

class ValidateNotNullToPollStatusColumn < ActiveRecord::Migration[7.2]
  def up
    connection.execute(<<~SQL.squish)
      DELETE FROM polls
      WHERE status_id IS NULL
    SQL

    validate_check_constraint :polls, name: 'polls_status_id_null'
    change_column_null :polls, :status_id, false
    remove_check_constraint :polls, name: 'polls_status_id_null'
  end

  def down
    add_check_constraint :polls, 'status_id IS NOT NULL', name: 'polls_status_id_null', validate: false
    change_column_null :polls, :status_id, true
  end
end
