class AddMissingIndices < ActiveRecord::Migration[4.2]
  def change
    add_index :users, :account_id
    add_index :statuses, :account_id
    add_index :statuses, :in_reply_to_id
    add_index :statuses, :reblog_of_id
    add_index :stream_entries, :account_id
    add_index :stream_entries, %i(activity_id activity_type)
  end
end
