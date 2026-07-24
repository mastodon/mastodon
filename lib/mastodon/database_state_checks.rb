# frozen_string_literal: true

module Mastodon
  module DatabaseStateChecks
    def check_database_state!
      return unless Rails.env.production?

      check_pending_pre_deployment_migrations!
      check_database_newer_than_code!
    end
    module_function :check_database_state!

    def check_pending_pre_deployment_migrations!
      migration_context = ActiveRecord::Base.connection_pool.migration_context
      pre_deployment_migrations = migration_context.migrations.filter_map { |migration| migration.version if migration.filename.start_with?('db/migrate') }
      return if (pre_deployment_migrations - migration_context.get_all_versions).empty?

      abort <<~MESSAGE # rubocop:disable Rails/Exit
        Some pre-deployment migrations are pending.
        Please run migrations (`SKIP_POST_DEPLOYMENT_MIGRATIONS=true RAILS_ENV=production bundle exec rails db:migrate`) before restarting Mastodon.
      MESSAGE
    end
    module_function :check_pending_pre_deployment_migrations!

    def check_database_newer_than_code!
      migration_context = ActiveRecord::Base.connection_pool.migration_context
      latest_known_migration = migration_context.migrations.pluck(:version).max
      current_version = migration_context.current_version
      return if [current_version, ENV.fetch('MASTODON_ALLOW_UKNOWN_MIGRATIONS', nil)].compact.max <= latest_known_migration

      abort <<~MESSAGE # rubocop:disable Rails/Exit
        You appear to be running code older than the last migrations you have run. Have you downgraded Mastodon without rolling back migrations?

        Running older Mastodon versions on a newer database version is unadvisable and unsupported.

        Please check that you are running the intended Mastodon version. If you did intend to downgrade, please make a backup of your database and
        roll back the migrations by doing `bundle exec rails db:migrate VERSION=#{latest_known_migration}` with the most recent code checked out.

        If you know what you are doing and do not want to roll back the migrations, please set `MASTODON_ALLOW_UNKNOWN_MIGRATIONS=#{current_version}`.
      MESSAGE
    end
    module_function :check_database_newer_than_code!
  end
end
