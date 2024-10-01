# frozen_string_literal: true

class AddMovedToAccountIdToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :moved_to_account_id, :bigint, null: true, default: nil
    safety_assured { add_foreign_key :accounts, :accounts, column: :moved_to_account_id, on_delete: :nullify }
  end
end
