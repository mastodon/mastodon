# frozen_string_literal: true

require 'rails_helper'
require 'rails/generators/testing/behavior'
require 'rails/generators/testing/assertions'

require 'generators/post_deployment_migration/post_deployment_migration_generator'

RSpec.describe PostDeploymentMigrationGenerator, type: :generator do
  include Rails::Generators::Testing::Behavior
  include Rails::Generators::Testing::Assertions
  include FileUtils

  tests described_class
  destination Rails.root.join('tmp', 'generator-test')
  before { prepare_destination }
  after { rm_rf(destination_root) }

  describe 'the migration' do
    it 'generates expected file' do
      run_generator %w(Changes)

      assert_migration('db/post_migrate/changes.rb', /disable_ddl/)
      assert_migration('db/post_migrate/changes.rb', /change/)
    end
  end
end
