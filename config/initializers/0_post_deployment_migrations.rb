# Post deployment migrations are included by default. This file must be loaded
# before other initializers as Rails may otherwise memoize a list of migrations
# excluding the post deployment migrations.

unless ENV['SKIP_POST_DEPLOYMENT_MIGRATIONS']
  Rails.application.config.paths['db'].each do |db_path|
    path = Rails.root.join(db_path, 'post_migrate').to_s

    Rails.application.config.paths['db/migrate'] << path

    # Rails memoizes migrations at certain points where it won't read the above
    # path just yet. As such we must also update the following list of paths.
    ActiveRecord::Migrator.migrations_paths << path
  end
end
