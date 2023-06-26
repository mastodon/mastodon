class AddStatusesIndexOnAccountIdId < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    # Statuses queried by account_id are often sorted by id. Querying statuses
    # of an account to show them in his status page is one of the most
    # significant examples.
    # Add this index to improve the performance in such cases.
    add_index 'statuses', %w(account_id id), algorithm: :concurrently, name: 'index_statuses_on_account_id_id'

    remove_index 'statuses', algorithm: :concurrently, column: 'account_id', name: 'index_statuses_on_account_id'
  end
end
