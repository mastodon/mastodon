# frozen_string_literal: true

# We are providing our own task with our own format
Rake::Task['db:encryption:init'].clear

namespace :db do
  namespace :encryption do
    desc 'Generate a set of keys for configuring Active Record encryption in a given environment'
    task :init do # rubocop:disable Rails/RakeEnvironment
      puts <<~MSG
        Add these secret environment variables to your Mastodon environment (e.g. .env.production):#{' '}

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
    version = ActiveRecord::Base.connection.database_version
    abort 'This version of Mastodon requires PostgreSQL 12.0 or newer. Please update PostgreSQL before updating Mastodon.' if version < 120_000
  end

  Rake::Task['db:migrate'].enhance(['db:pre_migration_check'])
end
