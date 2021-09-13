class ChangeAccountUriIndexToBtree < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def up
    add_index :accounts, :uri, name: :index_accounts_on_uri_btree, opclass: :text_pattern_ops, algorithm: :concurrently
    remove_index :accounts, :uri, name: :index_accounts_on_uri
    rename_index :accounts, :index_accounts_on_uri_btree, :index_accounts_on_uri
  end

  def down
    rename_index :accounts, :index_accounts_on_uri, :index_accounts_on_uri_btree
    add_index :accounts, :uri, name: :index_accounts_on_uri_btree, algorithm: :concurrently
    remove_index :accounts, :index_accounts_on_uri_btree
  end
end
