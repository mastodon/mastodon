# frozen_string_literal: true

class RemoveLegacyDeviseTwoFactorSecretsFromUsers < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      remove_column :users, :encrypted_otp_secret, :string
      remove_column :users, :encrypted_otp_secret_iv, :string
      remove_column :users, :encrypted_otp_secret_salt, :string
    end
  end
end
