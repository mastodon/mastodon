# frozen_string_literal: true

class CreateKeypairs < ActiveRecord::Migration[8.0]
  def change
    create_table :keypairs do |t|
      t.references :account, null: false, foreign_key: { on_delete: :cascade }

      t.string :uri, null: false
      t.integer :type, null: false
      t.string :public_key, null: false
      t.string :private_key
      t.datetime :expires_at
      t.boolean :revoked, default: false, null: false

      t.timestamps
    end

    add_index :keypairs, :uri, unique: true
  end
end
