# frozen_string_literal: true

class CreateRelays < ActiveRecord::Migration[5.2]
  def change
    create_table :relays do |t|
      t.string :inbox_url, default: '', null: false
      t.boolean :enabled, default: false, null: false, index: true

      t.string :follow_activity_id

      t.timestamps
    end
  end
end
