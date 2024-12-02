# frozen_string_literal: true

class AddFilteredIndexOnNotifications < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :notifications, [:account_id, :id, :type], where: 'filtered = false', order: { id: :desc }, name: 'index_notifications_on_filtered', algorithm: :concurrently
  end
end
