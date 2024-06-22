# frozen_string_literal: true

class CreateRelationshipSeveranceEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :relationship_severance_events do |t|
      t.integer :type, null: false
      t.string :target_name, null: false
      t.boolean :purged, null: false, default: false

      t.timestamps

      t.index [:type, :target_name]
    end
  end
end
