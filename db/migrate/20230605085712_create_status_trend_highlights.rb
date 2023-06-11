# frozen_string_literal: true

class CreateStatusTrendHighlights < ActiveRecord::Migration[6.1]
  def change
    create_table :status_trend_highlights do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.datetime :period, null: false
      t.bigint :status_id, null: false, index: { unique: true }
      t.bigint :account_id, null: false, index: true
      t.float :score, null: false, default: 0.0
      t.string :language
    end
  end
end
