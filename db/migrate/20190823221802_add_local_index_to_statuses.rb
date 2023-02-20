class AddLocalIndexToStatuses < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    add_index :statuses, %i(id account_id), name: :index_statuses_local_20190824, algorithm: :concurrently, order: { id: :desc }, where: '(local OR (uri IS NULL)) AND deleted_at IS NULL AND visibility = 0 AND reblog_of_id IS NULL AND ((NOT reply) OR (in_reply_to_account_id = account_id))'
  end

  def down
    remove_index :statuses, name: :index_statuses_local_20190824
  end
end
