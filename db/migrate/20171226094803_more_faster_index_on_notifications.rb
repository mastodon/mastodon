# frozen_string_literal: true

class MoreFasterIndexOnNotifications < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :notifications, [:account_id, :id], order: { id: :desc }, algorithm: :concurrently
    remove_index :notifications, [:id, :account_id, :activity_type], name: :index_notifications_on_id_and_account_id_and_activity_type
  end
end
