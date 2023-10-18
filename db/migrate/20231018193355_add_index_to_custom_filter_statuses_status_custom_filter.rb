# frozen_string_literal: true

class AddIndexToCustomFilterStatusesStatusCustomFilter < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :custom_filter_statuses, [:status_id, :custom_filter_id], unique: true, algorithm: :concurrently
  end
end
