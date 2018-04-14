# ensure activerecord tasks are loaded first
require "active_record/railtie"

module StrongMigrations
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/strong_migrations.rake"
    end
  end
end
