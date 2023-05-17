# frozen_string_literal: true

class CreateEmergencyRules < ActiveRecord::Migration[6.1]
  def change
    create_table :emergency_rules do |t|
      t.string :name, null: false
      t.integer :duration

      t.timestamps
    end
  end
end
