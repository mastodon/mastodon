# frozen_string_literal: true

class RemoveOldIndexOnAccountsUri < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    remove_index :accounts, :uri, name: :old_index_accounts_on_uri, algorithm: :concurrently
  end
end
