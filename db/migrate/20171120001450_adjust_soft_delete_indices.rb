class AdjustSoftDeleteIndices < ActiveRecord::Migration[5.1]
  def change
    remove_index :statuses, [:account_id, :id]
    remove_index :statuses, :conversation_id
    remove_index :statuses, :in_reply_to_id
    remove_index :statuses, :reblog_of_id

    commit_db_transaction

    add_index :statuses, [:account_id, :id], algorithm: :concurrently, where: 'deleted_at IS NULL'
    add_index :statuses, :conversation_id, algorithm: :concurrently, where: 'deleted_at IS NULL'
    add_index :statuses, :in_reply_to_id, algorithm: :concurrently, where: 'deleted_at IS NULL'
    add_index :statuses, :reblog_of_id, algorithm: :concurrently, where: 'deleted_at IS NULL'
  end
end
