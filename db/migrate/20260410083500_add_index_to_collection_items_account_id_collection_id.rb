# frozen_string_literal: true

class AddIndexToCollectionItemsAccountIdCollectionId < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    add_index_to_table
    remove_index :collection_items, [:account_id]
  end

  def down
    add_index :collection_items, [:account_id]
    remove_index_from_table
  end

  private

  def add_index_to_table
    add_index :collection_items, [:account_id, :collection_id], unique: true, algorithm: :concurrently
  rescue ActiveRecord::RecordNotUnique
    remove_index_from_table
    deduplicate_records
    retry
  end

  def remove_index_from_table
    remove_index :collection_items, [:account_id, :collection_id]
  end

  def deduplicate_records
    safety_assured do
      execute <<~SQL.squish
        DELETE FROM collection_items
          WHERE id NOT IN (
          SELECT DISTINCT ON(account_id, collection_id) id FROM collection_items
          ORDER BY account_id, collection_id, id ASC
        )
      SQL
    end
  end
end
