# frozen_string_literal: true

class AddCounterCacheToAccountModerationNoteOnTargetAccount < ActiveRecord::Migration[7.1]
  def up
    add_column :accounts, :targeted_moderation_notes_count, :integer, null: false, default: 0

    connection.execute(<<~SQL.squish)
      UPDATE accounts
      SET targeted_moderation_notes_count = (
        SELECT COUNT(*)
        FROM account_moderation_notes
        WHERE account_moderation_notes.target_account_id = accounts.id
      )
    SQL
  end

  def down
    remove_column :accounts, :targeted_moderation_notes_count
  end
end
