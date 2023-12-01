# frozen_string_literal: true

class CreateWebauthnCredentials < ActiveRecord::Migration[5.2]
  def change
    create_table :webauthn_credentials do |t|
      t.string :external_id, null: false
      t.string :public_key, null: false
      t.string :nickname, null: false
      t.bigint :sign_count, null: false, default: 0

      t.index :external_id, unique: true

      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
