class AddIndexAccountAndReblogOfIdToStatuses < ActiveRecord::Migration[5.1]
  def change
    commit_db_transaction
    add_index :statuses, [:account_id, :reblog_of_id], algorithm: :concurrently
  end
end
