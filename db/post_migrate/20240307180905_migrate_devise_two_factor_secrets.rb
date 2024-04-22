# frozen_string_literal: true

class MigrateDeviseTwoFactorSecrets < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  class MigrationUser < ApplicationRecord
    self.table_name = :users

    devise :two_factor_authenticatable,
           otp_secret_encryption_key: Rails.configuration.x.otp_secret

    include LegacyOtpSecret # Must be after the above `devise` line in order to override the legacy method
  end

  def up
    MigrationUser.reset_column_information

    users_with_otp_enabled.find_each do |user|
      # Gets the new value on already-updated users
      # Falls back to legacy value on not-yet-migrated users
      otp_secret = user.otp_secret

      Rails.logger.debug { "Processing #{user.email}" }

      # This is a no-op for migrated users and updates format for not migrated
      user.update!(otp_secret: otp_secret)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def users_with_otp_enabled
    MigrationUser.where(otp_required_for_login: true, otp_secret: nil)
  end
end
