ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'bootsnap' # Speed up boot time by caching expensive operations.

Bootsnap.setup(
  cache_dir:            'tmp/cache',
  development_mode:     ENV['RAILS_ENV'] == 'development',
  load_path_cache:      true,
  autoload_paths_cache: true,
  disable_trace:        true,
  compile_cache_iseq:   false,
  compile_cache_yaml:   false
)
