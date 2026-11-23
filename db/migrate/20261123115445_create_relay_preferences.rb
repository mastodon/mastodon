# frozen_string_literal: true

class CreateRelayPreferences < ActiveRecord::Migration[8.1]
  def change
    create_table :relay_preferences do |t|
      t.references :account, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.references :relay, null: false, foreign_key: { on_delete: :cascade }
      t.boolean :enabled, null: false, default: false

      t.timestamps
    end

    add_index :relay_preferences, [:account_id, :relay_id], unique: true
  end
end
