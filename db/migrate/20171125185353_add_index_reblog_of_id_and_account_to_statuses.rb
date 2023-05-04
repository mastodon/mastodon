class AddIndexReblogOfIdAndAccountToStatuses < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :statuses, [:reblog_of_id, :account_id], algorithm: :concurrently
  end
end
