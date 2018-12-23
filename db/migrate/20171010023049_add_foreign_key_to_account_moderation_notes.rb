class AddForeignKeyToAccountModerationNotes < ActiveRecord::Migration[5.1]
  def change
    add_foreign_key :account_moderation_notes, :accounts
  end
end
