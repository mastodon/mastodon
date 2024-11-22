# frozen_string_literal: true

class CreateReports < ActiveRecord::Migration[5.0]
  def change
    create_table :reports do |t|
      t.integer :account_id, null: false
      t.integer :target_account_id, null: false
      t.integer :status_ids, array: true, null: false, default: []
      t.text :comment, null: false, default: ''
      t.boolean :action_taken, null: false, default: false

      t.timestamps
    end
  end
end
