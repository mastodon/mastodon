require_relative '../bootsnap'

env = ENV['RAILS_ENV'] || ENV['RACK_ENV'] || ENV['ENV']
development_mode = ['', nil, 'development'].include?(env)

# only enable on 'ruby' (MRI), POSIX (darin, linux, *bsd), and >= 2.3.0
enable_cc =
  RUBY_ENGINE == 'ruby' &&
  RUBY_PLATFORM =~ /darwin|linux|bsd/ &&
  Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.3.0")

cache_dir = ENV['BOOTSNAP_CACHE_DIR']
unless cache_dir
  config_dir_frame = caller.detect do |line|
    line.include?('/config/')
  end

  unless config_dir_frame
    $stderr.puts "[bootsnap/setup] couldn't infer cache directory! Either:"
    $stderr.puts "[bootsnap/setup]   1. require bootsnap/setup from your application's config directory; or"
    $stderr.puts "[bootsnap/setup]   2. Define the environment variable BOOTSNAP_CACHE_DIR"

    raise "couldn't infer bootsnap cache directory"
  end

  path = config_dir_frame.split(/:\d+:/).first
  path = File.dirname(path) until File.basename(path) == 'config'
  app_root = File.dirname(path)

  cache_dir = File.join(app_root, 'tmp', 'cache')
end

Bootsnap.setup(
  cache_dir:            cache_dir,
  development_mode:     development_mode,
  load_path_cache:      true,
  autoload_paths_cache: true, # assume rails. open to PRs to impl. detection
  disable_trace:        false,
  compile_cache_iseq:   enable_cc,
  compile_cache_yaml:   enable_cc
)
