# frozen_string_literal: true

class ChangeUniqueIndexOnNotificationRequests < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    remove_index :notification_requests, [:account_id, :from_account_id], unique: true
    add_index :notification_requests, [:account_id, :from_account_id, :last_status_id], unique: true, algorithm: :concurrently
  end
end
