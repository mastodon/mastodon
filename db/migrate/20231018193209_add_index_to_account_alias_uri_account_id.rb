# frozen_string_literal: true

class AddIndexToAccountAliasUriAccountId < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :account_aliases, [:uri, :account_id], unique: true, algorithm: :concurrently
  end
end
