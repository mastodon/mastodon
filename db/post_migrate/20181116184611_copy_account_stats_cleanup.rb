# frozen_string_literal: true

class CopyAccountStatsCleanup < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured do
      remove_column :accounts, :statuses_count, :integer, default: 0, null: false
      remove_column :accounts, :following_count, :integer, default: 0, null: false
      remove_column :accounts, :followers_count, :integer, default: 0, null: false
    end
  end
end
