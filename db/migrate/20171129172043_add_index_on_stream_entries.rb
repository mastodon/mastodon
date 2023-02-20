class AddIndexOnStreamEntries < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_index :stream_entries, %i(account_id activity_type id), algorithm: :concurrently
    remove_index :stream_entries, name: :index_stream_entries_on_account_id
  end
end
