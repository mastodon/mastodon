# frozen_string_literal: true

class CreateAccountRelationshipSeveranceEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :account_relationship_severance_events do |t|
      t.belongs_to :account, foreign_key: { on_delete: :cascade }, null: false, index: { unique: true }
      t.belongs_to :relationship_severance_event, foreign_key: { on_delete: :cascade }, null: false, index: { unique: true }

      t.integer :relationships_count, default: 0, null: false

      t.timestamps
    end
  end
end
