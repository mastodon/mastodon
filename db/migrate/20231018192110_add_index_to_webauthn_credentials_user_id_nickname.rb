# frozen_string_literal: true

class AddIndexToWebauthnCredentialsUserIdNickname < ActiveRecord::Migration[7.0]
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
    add_index :webauthn_credentials, [:user_id, :nickname], unique: true, algorithm: :concurrently
  end

  def remove_index_from_table
    remove_index :webauthn_credentials, [:user_id, :nickname]
  end

  def deduplicate_records
    safety_assured do
      execute <<~SQL.squish
        DELETE FROM webauthn_credentials
          WHERE id NOT IN (
          SELECT DISTINCT ON(user_id, nickname) id FROM webauthn_credentials
          ORDER BY user_id, nickname, id ASC
        )
      SQL
    end
  end
end
