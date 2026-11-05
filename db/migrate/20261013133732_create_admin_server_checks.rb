# frozen_string_literal: true

class CreateAdminServerChecks < ActiveRecord::Migration[8.1]
  def change
    create_table :admin_server_checks do |t|
      t.string :key, null: false
      t.integer :status, limit: 1, default: 0, null: false
      t.integer :severity, limit: 1, default: 0, null: false
      t.boolean :ignored, default: false, null: false
      t.jsonb :data
      t.datetime :checked_at

      t.timestamps

      t.index [:key], unique: true
    end
  end
end
