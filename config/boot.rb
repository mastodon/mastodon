unless ENV.key?('RAILS_ENV')
  STDERR.puts 'ERROR: Missing RAILS_ENV environment variable, please set it to "production", "development", or "test".'
  exit 1
end

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'bootsnap' # Speed up boot time by caching expensive operations.

Bootsnap.setup(
  cache_dir:            File.expand_path('../tmp/cache', __dir__),
  development_mode:     ENV.fetch('RAILS_ENV', 'development') == 'development',
  ignore_directories:   ['cldr'],
  load_path_cache:      true,
  compile_cache_iseq:   false,
  compile_cache_yaml:   false
)
