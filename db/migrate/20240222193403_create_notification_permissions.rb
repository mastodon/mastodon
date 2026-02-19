# frozen_string_literal: true

class CreateNotificationPermissions < ActiveRecord::Migration[7.1]
  def change
    create_table :notification_permissions do |t|
      t.references :account, null: false, foreign_key: true
      t.references :from_account, null: false, foreign_key: { to_table: :accounts }

      t.timestamps
    end
  end
end
