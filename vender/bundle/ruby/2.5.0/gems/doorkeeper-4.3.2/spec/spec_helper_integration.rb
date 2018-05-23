if ENV['TRAVIS']
  require 'coveralls'

  Coveralls.wear!('rails') do
    add_filter('/spec/')
    add_filter('/lib/generators/doorkeeper/templates/')
  end
else
  require 'simplecov'

  SimpleCov.start do
    add_filter('/spec/')
    add_filter('/lib/generators/doorkeeper/templates/')
  end
end

ENV['RAILS_ENV'] ||= 'test'
TABLE_NAME_PREFIX = ENV['table_name_prefix'] || nil
TABLE_NAME_SUFFIX = ENV['table_name_suffix'] || nil

orm = (ENV['BUNDLE_GEMFILE'] || '').match(/Gemfile\.(.+)\.rb/)
DOORKEEPER_ORM = (orm && orm[1] || :active_record).to_sym

$LOAD_PATH.unshift File.dirname(__FILE__)

require 'capybara/rspec'
require 'dummy/config/environment'
require 'rspec/rails'
require 'generator_spec/test_case'
require 'database_cleaner'

# Load JRuby SQLite3 if in that platform
begin
  require 'jdbc/sqlite3'
  Jdbc::SQLite3.load_driver
rescue LoadError
end

Rails.logger.info "====> Doorkeeper.orm = #{Doorkeeper.configuration.orm}"
if Doorkeeper.configuration.orm == :active_record
  Rails.logger.info "======> active_record.table_name_prefix = #{Rails.configuration.active_record.table_name_prefix}"
  Rails.logger.info "======> active_record.table_name_suffix = #{Rails.configuration.active_record.table_name_suffix}"
end
Rails.logger.info "====> Rails version: #{Rails.version}"
Rails.logger.info "====> Ruby version: #{RUBY_VERSION}"

require "support/orm/#{DOORKEEPER_ORM}"

ENGINE_RAILS_ROOT = File.join(File.dirname(__FILE__), '../')

Dir["#{File.dirname(__FILE__)}/support/{dependencies,helpers,shared}/*.rb"].each { |f| require f }

# Remove after dropping support of Rails 4.2
require "#{File.dirname(__FILE__)}/support/http_method_shim.rb"

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.mock_with :rspec

  config.infer_base_class_for_anonymous_controllers = false

  config.include RSpec::Rails::RequestExampleGroup, type: :request

  config.before do
    DatabaseCleaner.start
    Doorkeeper.configure { orm DOORKEEPER_ORM }
  end

  config.after do
    DatabaseCleaner.clean
  end

  config.order = 'random'
end
