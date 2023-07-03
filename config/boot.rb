unless ENV.key?('RAILS_ENV')
  STDERR.puts 'ERROR: Missing RAILS_ENV environment variable, please set it to "production", "development", or "test".'
  exit 1
end

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
