# frozen_string_literal: true

namespace :db do
  namespace :migrate do
    desc 'Setup the db or migrate depending on state of db'
    task setup: :environment do
      begin
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
  end

  task :post_migration_hook do
    at_exit do
      unless %w(C POSIX).include?(ActiveRecord::Base.connection.execute('SELECT datcollate FROM pg_database WHERE datname = current_database();').first['datcollate'])
        warn <<~WARNING
          Your database collation is susceptible to index corruption.
            (This warning does not indicate that index corruption has occured and can be ignored)
            (To learn more, visit: https://docs.joinmastodon.org/admin/troubleshooting/index-corruption/)
        WARNING
      end
    end
  end

  Rake::Task['db:migrate'].enhance(['db:post_migration_hook'])
end
