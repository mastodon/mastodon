# frozen_string_literal: true
require 'test_helper'

class SimpleFormGeneratorTest < Rails::Generators::TestCase
  tests SimpleForm::Generators::InstallGenerator
  destination File.expand_path('../../tmp', __FILE__)
  setup :prepare_destination
  teardown { rm_rf(destination_root) }

  test 'generates example locale file' do
    run_generator
    assert_file 'config/locales/simple_form.en.yml'
  end

  test 'generates the simple_form initializer' do
    run_generator
    assert_file 'config/initializers/simple_form.rb',
      /config\.default_wrapper = :default/, /config\.boolean_style = :nested/
  end

  test 'generates the simple_form initializer with the bootstrap wrappers' do
    run_generator %w[--bootstrap]
    assert_file 'config/initializers/simple_form.rb',
      /config\.default_wrapper = :default/, /config\.boolean_style = :nested/
    assert_file 'config/initializers/simple_form_bootstrap.rb', /config\.wrappers :vertical_form/,
      /config\.wrappers :horizontal_form/, /config\.default_wrapper = :vertical_form/
  end

  test 'generates the simple_form initializer with the foundation wrappers' do
    run_generator %w[--foundation]
    assert_file 'config/initializers/simple_form.rb',
      /config\.default_wrapper = :default/, /config\.boolean_style = :nested/
    assert_file 'config/initializers/simple_form_foundation.rb', /config\.wrappers :vertical_form/,
      /config\.default_wrapper = :vertical_form/, /config\.item_wrapper_tag = :div/
  end

  %w[erb haml slim].each do |engine|
    test "generates the scaffold template when using #{engine}" do
      run_generator ['-e', engine]
      assert_file "lib/templates/#{engine}/scaffold/_form.html.#{engine}"
    end
  end
end
