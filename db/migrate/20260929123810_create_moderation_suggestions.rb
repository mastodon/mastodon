# frozen_string_literal: true

class CreateModerationSuggestions < ActiveRecord::Migration[8.1]
  def change
    create_table :moderation_suggestions do |t|
      t.belongs_to :moderation_subscription, foreign_key: { on_delete: :nullify }
      t.integer :state, null: false, default: 0
      t.integer :action, null: false
      t.integer :target_type, null: false
      t.string :target_key, null: false

      t.timestamps
    end

    add_index :moderation_suggestions, [:target_type, :target_key, :action], unique: true
  end
end
