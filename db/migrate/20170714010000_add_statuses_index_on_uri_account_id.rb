class AddStatusesIndexOnUriAccountId < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    # URI is not ensured to be unique across accounts, so index with accounts.
    add_index 'statuses', ['uri', 'account_id'], algorithm: :concurrently, name: 'index_statuses_on_uri_account_id', unique: true

    remove_index 'statuses', algorithm: :concurrently, column: 'uri', name: 'index_statuses_on_uri', unique: true
  end
end
