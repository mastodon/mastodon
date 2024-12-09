# frozen_string_literal: true

class CreateFaspProviders < ActiveRecord::Migration[7.2]
  def change
    create_table :fasp_providers do |t|
      t.boolean :confirmed, null: false, default: false
      t.string :name, null: false
      t.string :base_url, null: false, index: { unique: true }
      t.string :sign_in_url
      t.string :remote_identifier, null: false
      t.string :provider_public_key_pem, null: false
      t.string :server_private_key_pem, null: false
      t.jsonb :capabilities
      t.jsonb :privacy_policy
      t.string :contact_email
      t.string :fediverse_account

      t.timestamps
    end
  end
end
