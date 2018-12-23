class ChangeAccountsNonnullableInAccountModerationNotes < ActiveRecord::Migration[5.1]
  def change
    change_column_null :account_moderation_notes, :account_id, false
    change_column_null :account_moderation_notes, :target_account_id, false
  end
end
