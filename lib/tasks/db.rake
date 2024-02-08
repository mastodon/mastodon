# frozen_string_literal: true

namespace :db do
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
