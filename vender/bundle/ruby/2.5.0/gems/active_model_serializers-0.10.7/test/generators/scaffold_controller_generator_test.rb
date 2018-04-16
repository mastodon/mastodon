require 'test_helper'
require 'generators/rails/resource_override'

class ResourceGeneratorTest < Rails::Generators::TestCase
  destination File.expand_path('../../../tmp/generators', __FILE__)
  setup :prepare_destination, :copy_routes

  tests Rails::Generators::ResourceGenerator
  arguments %w(account)

  def test_serializer_file_is_generated
    run_generator

    assert_file 'app/serializers/account_serializer.rb', /class AccountSerializer < ActiveModel::Serializer/
  end

  private

  def copy_routes
    config_dir = File.join(destination_root, 'config')
    FileUtils.mkdir_p(config_dir)
    File.write(File.join(config_dir, 'routes.rb'), 'Rails.application.routes.draw {}')
  end
end
