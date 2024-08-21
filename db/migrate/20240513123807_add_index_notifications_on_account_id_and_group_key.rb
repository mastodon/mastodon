# frozen_string_literal: true

class AddIndexNotificationsOnAccountIdAndGroupKey < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :notifications, [:account_id, :group_key], algorithm: :concurrently, where: 'group_key IS NOT NULL'
  end
end
