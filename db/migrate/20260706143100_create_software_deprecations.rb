# frozen_string_literal: true

class CreateSoftwareDeprecations < ActiveRecord::Migration[8.1]
  def change
    create_table :software_deprecations do |t|
      t.string :branch, null: false
      t.date :end_of_support, null: false
      t.integer :warning_issued, null: false

      t.timestamps
    end

    add_index :software_deprecations, :branch, unique: true
  end
end
