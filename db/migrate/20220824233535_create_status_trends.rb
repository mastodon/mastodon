# frozen_string_literal: true

class CreateStatusTrends < ActiveRecord::Migration[6.1]
  def change
    create_table :status_trends do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.references :status, null: false, foreign_key: { on_delete: :cascade }, index: { unique: true }
      t.references :account, null: false, foreign_key: { on_delete: :cascade }
      t.float :score, null: false, default: 0
      t.integer :rank, null: false, default: 0
      t.boolean :allowed, null: false, default: false
      t.string :language
    end
  end
end
