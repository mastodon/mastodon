# frozen_string_literal: true

class CreateEmergencyTriggers < ActiveRecord::Migration[6.1]
  def change
    create_table :emergency_triggers do |t|
      t.belongs_to :emergency_rule, foreign_key: { on_delete: :cascade }, null: false

      t.string :event, null: false
      t.integer :threshold, null: false
      t.integer :duration_bucket, null: false

      t.timestamps
    end
  end
end
