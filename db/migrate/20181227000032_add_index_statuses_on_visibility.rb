class AddIndexStatusesOnVisibility < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  def change
    add_index :notifications, [:activity_type, :id], algorithm: :concurrently
    add_index :statuses, [:visibility, :id], algorithm: :concurrently, where: "(local = TRUE OR uri IS NULL)"
  end
end
