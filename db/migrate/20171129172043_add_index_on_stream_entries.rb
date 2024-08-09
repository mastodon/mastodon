# frozen_string_literal: true

class AddIndexOnStreamEntries < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :stream_entries, [:account_id, :activity_type, :id], algorithm: :concurrently
    remove_index :stream_entries, :account_id, name: :index_stream_entries_on_account_id
  end
end
