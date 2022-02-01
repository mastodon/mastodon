class AddDeletedAtIndexOnStatuses < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :statuses, :deleted_at, where: 'deleted_at IS NOT NULL', algorithm: :concurrently, if_not_exists: true
  end
end
