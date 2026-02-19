# frozen_string_literal: true

class ValidateChangeMentionStatusIdNonNullable < ActiveRecord::Migration[7.1]
  def up
    validate_check_constraint :mentions, name: 'mentions_status_id_null'
    change_column_null :mentions, :status_id, false
    remove_check_constraint :mentions, name: 'mentions_status_id_null'
  end

  def down
    add_check_constraint :mentions, 'status_id IS NOT NULL', name: 'mentions_status_id_null', validate: false
    change_column_null :mentions, :status_id, true
  end
end
