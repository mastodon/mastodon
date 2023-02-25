class RemoveDuplicateIndexesInLists < ActiveRecord::Migration[5.1]
  def change
    remove_index :list_accounts, name: 'index_list_accounts_on_account_id'
    remove_index :list_accounts, name: 'index_list_accounts_on_list_id'
  end
end
