class AddDeletedAtToStatuses < ActiveRecord::Migration[5.1]
  def change
    add_column :statuses, :deleted_at, :datetime, null: true, default: nil

    commit_db_transaction

    add_index :statuses, :deleted_at, algorithm: :concurrently
  end
end
