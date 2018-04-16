require 'simplecov'
require 'simplecov-rcov'
require "codeclimate-test-reporter"

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::RcovFormatter,
    CodeClimate::TestReporter::Formatter
  ]
)

SimpleCov.start do
  add_filter 'test'
end

CodeClimate::TestReporter.start

require 'minitest/autorun'

# Rails 4.0.x pins to an old minitest
unless defined?(MiniTest::Test)
  MiniTest::Test = MiniTest::Unit::TestCase
end

require 'active_record'
require 'data_mapper'
require 'digest/sha2'
require 'sequel'
ActiveSupport::Deprecation.behavior = :raise

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(File.dirname(__FILE__))
require 'attr_encrypted'

DB = if defined?(RUBY_ENGINE) && RUBY_ENGINE.to_sym == :jruby
  Sequel.jdbc('jdbc:sqlite::memory:')
else
  Sequel.sqlite
end

# The :after_initialize hook was removed in Sequel 4.0
# and had been deprecated for a while before that:
# http://sequel.rubyforge.org/rdoc-plugins/classes/Sequel/Plugins/AfterInitialize.html
# This plugin re-enables it.
Sequel::Model.plugin :after_initialize

SECRET_KEY = SecureRandom.random_bytes(32)

def base64_encoding_regex
  /^(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{4})$/
end

def drop_all_tables
  connection = ActiveRecord::Base.connection
  tables = (ActiveRecord::VERSION::MAJOR >= 5 ? connection.data_sources : connection.tables)
  tables.each { |table| ActiveRecord::Base.connection.drop_table(table) }
end
