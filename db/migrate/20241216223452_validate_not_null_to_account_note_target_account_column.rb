# frozen_string_literal: true

class ValidateNotNullToAccountNoteTargetAccountColumn < ActiveRecord::Migration[7.2]
  def up
    connection.execute(<<~SQL.squish)
      DELETE FROM account_notes
      WHERE target_account_id IS NULL
    SQL

    validate_check_constraint :account_notes, name: 'account_notes_target_account_id_null'
    change_column_null :account_notes, :target_account_id, false
    remove_check_constraint :account_notes, name: 'account_notes_target_account_id_null'
  end

  def down
    add_check_constraint :account_notes, 'target_account_id IS NOT NULL', name: 'account_notes_target_account_id_null', validate: false
    change_column_null :account_notes, :target_account_id, true
  end
end
