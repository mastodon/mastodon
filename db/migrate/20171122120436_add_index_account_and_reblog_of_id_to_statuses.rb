class AddIndexAccountAndReblogOfIdToStatuses < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def up
    # This index has been superseded by migration 20171125185353
    # add_index :statuses, [:account_id, :reblog_of_id], algorithm: :concurrently
  end

  def down
    remove_index :statuses, %i(account_id reblog_of_id) if index_exists?(:statuses, %i(account_id reblog_of_id))
  end
end
