# frozen_string_literal: true

class RemoveIndexNotificationsOnAccountActivity < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    remove_index :notifications, name: :account_activity
  end

  def down
    add_index :notifications, [:account_id, :activity_id, :activity_type], unique: true, name: 'account_activity', algorithm: :concurrently
  end
end
