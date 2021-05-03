class AddFixedLowercaseIndexToAccounts < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    rename_index :accounts, 'index_accounts_on_username_and_domain_lower', 'old_index_accounts_on_username_and_domain_lower' unless index_name_exists?(:accounts, 'old_index_accounts_on_username_and_domain_lower')
    add_index :accounts, "lower (username), COALESCE(lower(domain), '')", name: 'index_accounts_on_username_and_domain_lower', unique: true, algorithm: :concurrently
    remove_index :accounts, name: 'old_index_accounts_on_username_and_domain_lower'
  end

  def down
    add_index :accounts, 'lower (username), lower(domain)', name: 'old_index_accounts_on_username_and_domain_lower', unique: true, algorithm: :concurrently
    remove_index :accounts, name: 'index_accounts_on_username_and_domain_lower'
    rename_index :accounts, 'old_index_accounts_on_username_and_domain_lower', 'index_accounts_on_username_and_domain_lower'
  end
end
