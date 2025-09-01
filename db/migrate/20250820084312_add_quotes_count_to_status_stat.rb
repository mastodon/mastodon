# frozen_string_literal: true

class AddQuotesCountToStatusStat < ActiveRecord::Migration[8.0]
  def change
    add_column :status_stats, :quotes_count, :bigint, null: false, default: 0
  end
end
