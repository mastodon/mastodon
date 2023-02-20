# frozen_string_literal: true

class RemoveIndexNotificationsOnAccountActivity < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    remove_index :notifications, name: :account_activity
    remove_index :notifications, name: :index_notifications_on_account_id_and_id
  end

  def down
    add_index :notifications, %i(account_id activity_id activity_type), unique: true, name: 'account_activity', algorithm: :concurrently
    add_index :notifications, %i(account_id id), order: { id: :desc }, algorithm: :concurrently
  end
end
