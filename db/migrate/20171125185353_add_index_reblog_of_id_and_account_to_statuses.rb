class AddIndexReblogOfIdAndAccountToStatuses < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_index :statuses, %i(reblog_of_id account_id), algorithm: :concurrently
  end
end
