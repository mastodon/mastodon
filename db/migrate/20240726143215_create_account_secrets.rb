# frozen_string_literal: true

class CreateAccountSecrets < ActiveRecord::Migration[7.1]
  def change
    create_table :account_secrets do |t|
      t.text :private_key
      t.references :account, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
