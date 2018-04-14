# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'
require 'bundler/setup'

begin
  require 'simplecov'
  AppCoverage.start
rescue LoadError
  STDERR.puts 'Running without SimpleCov'
end

require 'pry'
require 'timecop'
require 'rails'
require 'action_controller'
require 'action_controller/test_case'
require 'action_controller/railtie'
require 'active_model_serializers'
# For now, we only restrict the options to serializable_hash/as_json/to_json
# in tests, to ensure developers don't add any unsupported options.
# There's no known benefit, at this time, to having the filtering run in
# production when the excluded options would simply not be used.
#
# However, for documentation purposes, the constant
# ActiveModel::Serializer::SERIALIZABLE_HASH_VALID_KEYS is defined
# in the Serializer.
ActiveModelSerializers::Adapter::Base.class_eval do
  alias_method :original_serialization_options, :serialization_options

  def serialization_options(options)
    original_serialization_options(options)
      .slice(*ActiveModel::Serializer::SERIALIZABLE_HASH_VALID_KEYS)
  end
end
require 'fileutils'
FileUtils.mkdir_p(File.expand_path('../../tmp/cache', __FILE__))

gem 'minitest'
require 'minitest'
require 'minitest/autorun'
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

module TestHelper
  module_function

  def silence_warnings
    original_verbose = $VERBOSE
    $VERBOSE = nil
    yield
  ensure
    $VERBOSE = original_verbose
  end
end

require 'support/rails_app'

# require "rails/test_help"

require 'support/serialization_testing'

require 'support/rails5_shims'

require 'fixtures/active_record'

require 'fixtures/poro'

ActiveSupport.on_load(:action_controller) do
  $action_controller_logger = ActiveModelSerializers.logger
  ActiveModelSerializers.logger = Logger.new(IO::NULL)
end
