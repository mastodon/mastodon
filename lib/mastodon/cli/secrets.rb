# frozen_string_literal: true

require_relative 'base'

module Mastodon::CLI
  class Secrets < Base
    option :concurrency, type: :numeric, default: 5, aliases: [:c]
    option :dry_run, type: :boolean
    desc 'db-reencrypt', 'Re-encrypt records using a new encryption key'
    long_desc <<~LONG_DESC
      Re-encrypt all records in the database using a new encryption key.

      This is useful during encryption key rotation. The new key must already be active, and the old key still available.

      This task can be performed live, while the Mastodon is running.
    LONG_DESC
    def db_reencrypt
      if Rails.configuration.active_record.encryption.primary_key.length < 2
        fail_with_message <<~ERROR
          Both the old and the new encryption key are required to re-encrypt the records in the database.
          Ensure that ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY contains both, separated by a comma.
        ERROR
      end

      processed, = parallelize_with_progress(Keypair.where.not(private_key: nil)) { |record| record.encrypt unless dry_run? }
      say("Processed #{processed} keypairs#{dry_run_mode_suffix}", :green)

      processed, = parallelize_with_progress(User.where.not(otp_secret: nil)) { |record| record.encrypt unless dry_run? }
      say("Processed #{processed} OTP secrets#{dry_run_mode_suffix}", :green)
    end
  end
end
