# frozen_string_literal: true

class CreateFaspBackfillRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :fasp_backfill_requests do |t|
      t.string :category, null: false
      t.integer :max_count, null: false, default: 100
      t.string :cursor
      t.boolean :fulfilled, null: false, default: false
      t.references :fasp_provider, null: false, foreign_key: true

      t.timestamps
    end
  end
end
