# frozen_string_literal: true

class AddIndexToIdentitiesUidProvider < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    deduplicate_records
    add_index_to_table
  end

  def down
    remove_index_from_table
  end

  private

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
