# frozen_string_literal: true

class CreateFaspStatusTrends < ActiveRecord::Migration[8.0]
  def change
    create_table :fasp_status_trends do |t|
      t.references :status, null: false, foreign_key: true
      t.references :fasp_provider, null: false, foreign_key: true
      t.integer :rank, null: false
      t.string :language, null: false
      t.boolean :allowed, null: false, default: false

      t.timestamps
    end
  end
end
