class AddIndexNotificationsOnType < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :notifications, [:account_id, :type], algorithm: :concurrently
  end
end
