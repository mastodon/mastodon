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

      # We are about to dynamically look up ActiveRecord models so ensure they are all loaded first
      Zeitwerk::Loader.eager_load_all

      # Identify every model that uses ActiveRecord encryption
      encrypted_models = ObjectSpace.each_object(Class)
        .select { |c| c.include? ActiveRecord::Encryption::EncryptableRecord }
        .select { |c| c.encrypted_attributes.present? }

      model_count = encrypted_models.length.to_s
      say("Updating encrypted fields on #{model_count} models#{dry_run_mode_suffix}")

      encrypted_models.each.with_index(1) do |model, index|
        # Skip columns using deterministic encryption since those cannot be rotated
        encrypted_attrs = model.encrypted_attributes
          .reject { |attr| model.type_for_attribute(attr).deterministic? }

        # Pretty print e.g. "( 5/23)"
        msg_prefix = "(#{index.to_s.rjust(model_count.length)}/#{model_count})"

        if encrypted_attrs.empty?
          say("#{msg_prefix} Skipping #{model.name} which only uses deterministic encryption#{dry_run_mode_suffix}", :green)
          next
        end

        # Make a query like `encrypted_col_a IS NOT NULL OR encrypted_col_b IS NOT NULL OR ...`
        scope = encrypted_attrs.map { |attr| model.arel_table[attr].not_eq(nil) }.reduce(&:or)
        processed, = parallelize_with_progress(model.where(scope)) { |record| record.encrypt unless dry_run? }
        say("#{msg_prefix} Processed #{processed} #{model.name} records#{dry_run_mode_suffix}", :green)
      end
    end
  end
end
