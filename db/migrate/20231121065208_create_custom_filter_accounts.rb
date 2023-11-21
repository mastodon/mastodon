# frozen_string_literal: true

class CreateCustomFilterAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :custom_filter_accounts do |t|
      t.belongs_to :custom_filter, foreign_key: { on_delete: :cascade }, null: false, index: false
      t.belongs_to :target_account, foreign_key: { to_table: :accounts, on_delete: :cascade }, null: false
      t.timestamps

      t.index [:custom_filter_id, :target_account_id], unique: true
    end
  end
end
