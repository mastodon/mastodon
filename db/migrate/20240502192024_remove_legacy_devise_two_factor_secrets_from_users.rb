# frozen_string_literal: true

class RemoveLegacyDeviseTwoFactorSecretsFromUsers < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      remove_column :users, :encrypted_otp_secret
      remove_column :users, :encrypted_otp_secret_iv
      remove_column :users, :encrypted_otp_secret_salt
    end
  end
end
