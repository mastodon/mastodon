# frozen_string_literal: true

class AddIndexToWebauthnCredentialsUserIdNickname < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :webauthn_credentials, [:nickname, :user_id], unique: true, algorithm: :concurrently
  end
end
