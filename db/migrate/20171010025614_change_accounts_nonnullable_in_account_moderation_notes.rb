# frozen_string_literal: true

class ChangeAccountsNonnullableInAccountModerationNotes < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      change_column_null :account_moderation_notes, :account_id, false
      change_column_null :account_moderation_notes, :target_account_id, false
    end
  end
end
