# frozen_string_literal: true

# We are providing our own task with our own format
Rake::Task['db:encryption:init'].clear

namespace :db do
  namespace :encryption do
    desc 'Generate a set of keys for configuring Active Record encryption in a given environment'
    task :init do # rubocop:disable Rails/RakeEnvironment
      if %w(
        ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY
        ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT
        ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY
      ).any? { |key| ENV[key].present? }
        unless ENV['IGNORE_ALREADY_SET_SECRETS'] == 'true'
          puts <<~MSG
            Secrets for this server have already been set, this step can likely be ignored!
            In the unlikely event you need to generate new secrets, re-run this command with `IGNORE_ALREADY_SET_SECRETS=true`.
          MSG

          next
        end

        pastel = Pastel.new
        puts pastel.red(<<~MSG)
          WARNING: It looks like encryption secrets have already been set.
          WARNING: Ensure you are not changing secrets for a Mastodon installation that already uses them, as this will cause data loss and other issues that are difficult to recover from.
          WARNING: Only proceed if you are absolutely sure of what you are doing!
        MSG

        puts <<~MSG
          If you are sure of what you are doing, add the following secret environment variables to your Mastodon environment (e.g. .env.production), ensure they are shared across all your nodes and do not change them after they are set:#{' '}
        MSG
      else
        puts <<~MSG
          Add the following secret environment variables to your Mastodon environment (e.g. .env.production), ensure they are shared across all your nodes and do not change them after they are set:#{' '}
        MSG
      end

      puts <<~MSG

        # Do NOT change these variables once they are set
        ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=#{SecureRandom.alphanumeric(32)}
        ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=#{SecureRandom.alphanumeric(32)}
        ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=#{SecureRandom.alphanumeric(32)}
      MSG
    end
  end

  namespace :migrate do
    desc 'Setup the db or migrate depending on state of db'
    task setup: :environment do
      if ActiveRecord::Migrator.current_version.zero?
        Rake::Task['db:migrate'].invoke
        Rake::Task['db:seed'].invoke
      end
    rescue ActiveRecord::NoDatabaseError
      Rake::Task['db:setup'].invoke
    else
      Rake::Task['db:migrate'].invoke
    end
  end

  task pre_migration_check: :environment do
    pg_version = ActiveRecord::Base.connection.database_version
    abort 'This version of Mastodon requires PostgreSQL 14.0 or newer. Please update PostgreSQL before updating Mastodon.' if pg_version < 140_000

    schema_version = ActiveRecord::Migrator.current_version
    abort <<~MESSAGE if ENV['SKIP_POST_DEPLOYMENT_MIGRATIONS'] && schema_version < 2023_09_07_150100
      Zero-downtime migrations from Mastodon versions earlier than 4.2.0 are not supported.
      Please update to Mastodon 4.2.x first or upgrade by stopping all services and running migrations without `SKIP_POST_DEPLOYMENT_MIGRATIONS`.
    MESSAGE
  end

  Rake::Task['db:migrate'].enhance(['db:pre_migration_check'])
end
