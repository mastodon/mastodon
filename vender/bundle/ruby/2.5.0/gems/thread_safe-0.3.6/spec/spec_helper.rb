require 'simplecov'
require 'coveralls'
require 'logger'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
]

SimpleCov.start do
  project_name 'thread_safe'
  add_filter '/coverage/'
  add_filter '/pkg/'
  add_filter '/spec/'
  add_filter '/tasks/'
  add_filter '/yard-template/'
end

$VERBOSE = nil # suppress our deprecation warnings
require 'thread_safe'

logger                          = Logger.new($stderr)
logger.level                    = Logger::WARN

# import all the support files
Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require File.expand_path(f) }

RSpec.configure do |config|
  #config.raise_errors_for_deprecations!
  config.order = 'random'
end