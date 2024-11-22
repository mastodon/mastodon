# frozen_string_literal: true

class ValidateChangeMentionAccountIdNonNullable < ActiveRecord::Migration[7.1]
  def up
    validate_check_constraint :mentions, name: 'mentions_account_id_null'
    change_column_null :mentions, :account_id, false
    remove_check_constraint :mentions, name: 'mentions_account_id_null'
  end

  def down
    add_check_constraint :mentions, 'account_id IS NOT NULL', name: 'mentions_account_id_null', validate: false
    change_column_null :mentions, :account_id, true
  end
end
