class AddIndexNotificationsOnType < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :notifications, %i(account_id id type), order: { id: :desc }, algorithm: :concurrently
  end
end
