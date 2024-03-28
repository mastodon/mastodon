# frozen_string_literal: true

class AddTargetAccountForeignKeyToPreviewCards < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :preview_cards, :accounts, column: :target_account_id, on_delete: :cascade, validate: false
  end
end
