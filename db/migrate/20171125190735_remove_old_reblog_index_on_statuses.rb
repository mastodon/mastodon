# frozen_string_literal: true

class RemoveOldReblogIndexOnStatuses < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    # This index may not exists (see migration 20171122120436)
    remove_index :statuses, [:account_id, :reblog_of_id] if index_exists?(:statuses, [:account_id, :reblog_of_id])

    remove_index :statuses, :reblog_of_id
  end

  def down
    add_index :statuses, :reblog_of_id, algorithm: :concurrently
  end
end
