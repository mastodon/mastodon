class AddIndexForTrendTags < ActiveRecord::Migration[5.1]
  def change
    commit_db_transaction
    add_index :statuses, [:created_at, :local, :id], algorithm: :concurrently
  end
end
