# frozen_string_literal: true

class CreateAccountSecrets < ActiveRecord::Migration[8.0]
  def change
    create_table :account_secrets do |t|
      t.references :account, null: false, foreign_key: { on_delete: :cascade }, index: { unique: true }
      t.text :private_key

      t.timestamps
    end
  end
end
