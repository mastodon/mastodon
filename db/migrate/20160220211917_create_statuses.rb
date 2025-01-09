# frozen_string_literal: true

class CreateStatuses < ActiveRecord::Migration[4.2]
  def change
    create_table :statuses do |t|
      t.string :uri, null: false, default: ''
      t.integer :account_id, null: false
      t.text :text, null: false, default: ''

      t.timestamps null: false
    end

    add_index :statuses, :uri, unique: true
  end
end
