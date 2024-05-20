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
      otp_secret = begin
        user.otp_secret
      rescue OpenSSL::OpenSSLError
        next if ENV['MIGRATION_IGNORE_INVALID_OTP_SECRET'] == 'true'

        abort_with_decryption_error(user)
      end

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

  def abort_with_decryption_error(user)
    abort <<~MESSAGE

      ERROR: Unable to decrypt OTP secret for user #{user.id}.

      This is most likely because you have changed the value of `OTP_SECRET` at some point in
      time after the user configured 2FA.

      In this case, their OTP secret had already been lost with the change to `OTP_SECRET`, and
      proceeding with this migration will not make the situation worse.

      Please double-check that you have not accidentally changed `OTP_SECRET` just for this
      migration, and re-run the migration with `MIGRATION_IGNORE_INVALID_OTP_SECRET=true`.

      Migration aborted.
    MESSAGE
  end
end
