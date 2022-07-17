class AddIndexStatusesOnAccountId < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :statuses, [:account_id], name: :index_statuses_on_account_id, algorithm: :concurrently
  end
end
