# frozen_string_literal: true

class CreateSoftwareUpdates < ActiveRecord::Migration[7.0]
  def change
    create_table :software_updates do |t|
      t.string :version, null: false
      t.boolean :urgent, default: false, null: false
      t.integer :type, default: 0, null: false
      t.string :release_notes, default: '', null: false

      t.timestamps
    end

    add_index :software_updates, :version, unique: true
  end
end
