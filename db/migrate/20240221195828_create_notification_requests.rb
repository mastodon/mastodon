# frozen_string_literal: true

class CreateNotificationRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :notification_requests do |t|
      t.references :account, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.references :from_account, null: false, foreign_key: { to_table: :accounts, on_delete: :cascade }
      t.references :last_status, null: false, foreign_key: { to_table: :statuses, on_delete: :nullify }
      t.bigint :notifications_count, null: false, default: 0
      t.boolean :dismissed, null: false, default: false

      t.timestamps
    end

    add_index :notification_requests, [:account_id, :from_account_id], unique: true
    add_index :notification_requests, [:account_id, :id], where: 'dismissed = false', order: { id: :desc }
  end
end
