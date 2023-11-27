# frozen_string_literal: true

class AddIndexToWebauthnCredentialsUserIdNickname < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    safety_assured do
      execute <<~SQL.squish
        DELETE FROM webauthn_credentials
          WHERE id NOT IN (
          SELECT DISTINCT ON(nickname, user_id) id FROM webauthn_credentials
          ORDER BY nickname, user_id, id ASC
        )
      SQL
    end

    add_index :webauthn_credentials, [:nickname, :user_id], unique: true, algorithm: :concurrently
  end

  def down
    remove_index :webauthn_credentials, [:nickname, :user_id]
  end
end
