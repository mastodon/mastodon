# frozen_string_literal: true

class AddNotNullToAccountNoteAccountColumn < ActiveRecord::Migration[7.2]
  def change
    add_check_constraint :account_notes, 'account_id IS NOT NULL', name: 'account_notes_account_id_null', validate: false
  end
end
