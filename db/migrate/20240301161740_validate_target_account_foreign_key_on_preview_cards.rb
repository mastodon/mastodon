# frozen_string_literal: true

class ValidateTargetAccountForeignKeyOnPreviewCards < ActiveRecord::Migration[7.1]
  def change
    validate_foreign_key :preview_cards, column: :target_account_id
  end
end
