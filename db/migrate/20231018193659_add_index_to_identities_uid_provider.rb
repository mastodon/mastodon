# frozen_string_literal: true

class AddIndexToIdentitiesUidProvider < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_index_to_table
  rescue ActiveRecord::RecordNotUnique
    remove_duplicates_and_reindex
  end

  def down
    remove_index_from_table
  end

  private

  def remove_duplicates_and_reindex
    deduplicate_records
    reindex_records
  rescue ActiveRecord::RecordNotUnique
    retry
  end

  def reindex_records
    remove_index_from_table
    add_index_to_table
  end

  def add_index_to_table
    add_index :identities, [:uid, :provider], unique: true, algorithm: :concurrently
  end

  def remove_index_from_table
    remove_index :identities, [:uid, :provider]
  end

  def deduplicate_records
    safety_assured do
      execute <<~SQL.squish
        DELETE FROM identities
          WHERE id NOT IN (
          SELECT DISTINCT ON(uid, provider) id FROM identities
          ORDER BY uid, provider, id ASC
        )
      SQL
    end
  end
end
