# frozen_string_literal: true

class RemoveDuplicateIndexesInLists < ActiveRecord::Migration[5.2]
  def change
    remove_index :list_accounts, :account_id, name: 'index_list_accounts_on_account_id'
    remove_index :list_accounts, :list_id, name: 'index_list_accounts_on_list_id'
  end
end
