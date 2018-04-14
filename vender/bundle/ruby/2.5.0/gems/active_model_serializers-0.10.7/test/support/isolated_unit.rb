# https://github.com/rails/rails/blob/v5.0.0.beta1/railties/test/isolation/abstract_unit.rb

# Usage Example:
#
# require 'support/isolated_unit'
#
# class RailtieTest < ActiveSupport::TestCase
#   include ActiveSupport::Testing::Isolation
#
#   class WithRailsDefinedOnLoad < RailtieTest
#     setup do
#       require 'rails'
#       require 'active_model_serializers'
#       make_basic_app
#     end
#
#     # some tests
#   end
#
#   class WithoutRailsDefinedOnLoad < RailtieTest
#     setup do
#       require 'active_model_serializers'
#       make_basic_app
#     end
#
#     # some tests
#   end
# end
#
# Note:
# It is important to keep this file as light as possible
# the goal for tests that require this is to test booting up
# rails from an empty state, so anything added here could
# hide potential failures
#
# It is also good to know what is the bare minimum to get
# Rails booted up.
require 'bundler/setup' unless defined?(Bundler)
require 'active_support'
require 'active_support/core_ext/string/access'

# These files do not require any others and are needed
# to run the tests
require 'active_support/testing/autorun'
require 'active_support/testing/isolation'

module TestHelpers
  module Generation
    module_function

    # Make a very basic app, without creating the whole directory structure.
    # Is faster and simpler than generating a Rails app in a temp directory
    def make_basic_app
      require 'rails'
      require 'action_controller/railtie'

      app = Class.new(Rails::Application) do
        config.eager_load = false
        config.session_store :cookie_store, key: '_myapp_session'
        config.active_support.deprecation = :log
        config.active_support.test_order = :parallel
        ActiveSupport::TestCase.respond_to?(:test_order=) && ActiveSupport::TestCase.test_order = :parallel
        config.root = File.dirname(__FILE__)
        config.log_level = :info
        # Set a fake logger to avoid creating the log directory automatically
        fake_logger = Logger.new(nil)
        config.logger = fake_logger
        Rails.application.routes.default_url_options = { host: 'example.com' }
      end
      def app.name; 'IsolatedRailsApp'; end # rubocop:disable Style/SingleLineMethods
      app.respond_to?(:secrets) && app.secrets.secret_key_base = '3b7cd727ee24e8444053437c36cc66c4'

      @app = app
      yield @app if block_given?
      @app.initialize!
    end
  end
end

module ActiveSupport
  class TestCase
    include TestHelpers::Generation
  end
end
