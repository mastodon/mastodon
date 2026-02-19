# frozen_string_literal: true

class CreateAnnualReportStatusesPerAccountCounts < ActiveRecord::Migration[7.1]
  def change
    create_table :annual_report_statuses_per_account_counts do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.integer :year, null: false
      t.bigint :account_id, null: false
      t.bigint :statuses_count, null: false
    end

    add_index :annual_report_statuses_per_account_counts, [:year, :account_id], unique: true
  end
end
