# frozen_string_literal: true

class CopyStatusStatsCleanup < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured do
      remove_column :statuses, :reblogs_count, :integer, default: 0, null: false
      remove_column :statuses, :favourites_count, :integer, default: 0, null: false
    end
  end
end
