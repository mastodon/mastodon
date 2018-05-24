class AddIndexAccountsNotSilenced < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!
  
  def change
    add_index :accounts,[:id], where: 'not silenced', algorithm: :concurrently, name: "index_accounts_not_silenced"
  end
end

