require 'rails/generators/active_record'

class Doorkeeper::ApplicationOwnerGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  source_root File.expand_path('../templates', __FILE__)
  desc 'Provide support for client application ownership.'

  def application_owner
    migration_template(
      'add_owner_to_application_migration.rb.erb',
      'db/migrate/add_owner_to_application.rb',
      migration_version: migration_version
    )
  end

  def self.next_migration_number(dirname)
    ActiveRecord::Generators::Base.next_migration_number(dirname)
  end

  private

  def migration_version
    if ActiveRecord::VERSION::MAJOR >= 5
      "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
    end
  end
end
