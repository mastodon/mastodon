# frozen_string_literal: true

class AddForeignKeyToAccountModerationNotes < ActiveRecord::Migration[5.2]
  def change
    safety_assured { add_foreign_key :account_moderation_notes, :accounts }
  end
end
