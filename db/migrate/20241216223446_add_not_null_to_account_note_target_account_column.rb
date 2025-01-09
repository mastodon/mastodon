# frozen_string_literal: true

class AddNotNullToAccountNoteTargetAccountColumn < ActiveRecord::Migration[7.2]
  def change
    add_check_constraint :account_notes, 'target_account_id IS NOT NULL', name: 'account_notes_target_account_id_null', validate: false
  end
end
