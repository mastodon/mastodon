require 'rails/generators'
require 'rails/generators/migration'

module Settings
  class InstallGenerator < Rails::Generators::NamedBase
    desc 'Generate RailsSettings files.'
    include Rails::Generators::Migration

    argument :name, type: :string, default: 'setting'

    source_root File.expand_path('../templates', __FILE__)

    @@migrations = false

    def self.next_migration_number(dirname) #:nodoc:
      if ActiveRecord::Base.timestamped_migrations
        if @@migrations
          (current_migration_number(dirname) + 1)
        else
          @@migrations = true
          Time.now.utc.strftime('%Y%m%d%H%M%S')
        end
      else
        format '%.3d', current_migration_number(dirname) + 1
      end
    end

    def install_setting
      template 'model.rb', File.join('app/models', class_path, "#{file_name}.rb")
      template 'app.yml', File.join('config', 'app.yml')
      migration_template 'migration.rb', 'db/migrate/create_settings.rb', migration_version: migration_version
    end

    def rails5?
      Rails.version.start_with? '5'
    end

    def migration_version
      "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]" if rails5?
    end
  end
end
