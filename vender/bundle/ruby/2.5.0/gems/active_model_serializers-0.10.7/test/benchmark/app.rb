# https://github.com/rails-api/active_model_serializers/pull/872
# approx ref 792fb8a9053f8db3c562dae4f40907a582dd1720 to test against
require 'bundler/setup'

require 'rails'
require 'active_model'
require 'active_support'
require 'active_support/json'
require 'action_controller'
require 'action_controller/test_case'
require 'action_controller/railtie'
abort "Rails application already defined: #{Rails.application.class}" if Rails.application

class NullLogger < Logger
  def initialize(*_args)
  end

  def add(*_args, &_block)
  end
end
class BenchmarkLogger < ActiveSupport::Logger
  def initialize
    @file = StringIO.new
    super(@file)
  end

  def messages
    @file.rewind
    @file.read
  end
end
# ref: https://gist.github.com/bf4/8744473
class BenchmarkApp < Rails::Application
  # Set up production configuration
  config.eager_load = true
  config.cache_classes = true
  # CONFIG: CACHE_ON={on,off}
  config.action_controller.perform_caching = ENV['CACHE_ON'] != 'off'
  config.action_controller.cache_store = ActiveSupport::Cache.lookup_store(:memory_store)

  config.active_support.test_order = :random
  config.secret_token = 'S' * 30
  config.secret_key_base = 'abc123'
  config.consider_all_requests_local = false

  # otherwise deadlock occurred
  config.middleware.delete 'Rack::Lock'

  # to disable log files
  config.logger = NullLogger.new
  config.active_support.deprecation = :log
  config.log_level = :info
end

require 'active_model_serializers'

# Initialize app before any serializers are defined, for running across revisions.
# ref: https://github.com/rails-api/active_model_serializers/pull/1478
Rails.application.initialize!
# HACK: Serializer::cache depends on the ActionController-dependent configs being set.
ActiveSupport.on_load(:action_controller) do
  require_relative 'fixtures'
end

require_relative 'controllers'
