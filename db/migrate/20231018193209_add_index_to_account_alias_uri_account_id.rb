# frozen_string_literal: true

class AddIndexToAccountAliasUriAccountId < ActiveRecord::Migration[7.0]
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
    add_index :account_aliases, [:uri, :account_id], unique: true, algorithm: :concurrently
  end

  def remove_index_from_table
    remove_index :account_aliases, [:uri, :account_id]
  end

  def deduplicate_records
    safety_assured do
      execute <<~SQL.squish
        DELETE FROM account_aliases
          WHERE id NOT IN (
          SELECT DISTINCT ON(uri, account_id) id FROM account_aliases
          ORDER BY uri, account_id, id ASC
        )
      SQL
    end
  end
end
