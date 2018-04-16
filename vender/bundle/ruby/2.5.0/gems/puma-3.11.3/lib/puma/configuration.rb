require 'puma/rack/builder'
require 'puma/plugin'
require 'puma/const'

module Puma

  module ConfigDefault
    DefaultRackup = "config.ru"

    DefaultTCPHost = "0.0.0.0"
    DefaultTCPPort = 9292
    DefaultWorkerTimeout = 60
    DefaultWorkerShutdownTimeout = 30
  end

  # A class used for storing "leveled" configuration options.
  #
  # In this class any "user" specified options take precedence over any
  # "file" specified options, take precedence over any "default" options.
  #
  # User input is prefered over "defaults":
  #   user_options    = { foo: "bar" }
  #   default_options = { foo: "zoo" }
  #   options = UserFileDefaultOptions.new(user_options, default_options)
  #   puts options[:foo]
  #   # => "bar"
  #
  # All values can be accessed via `all_of`
  #
  #   puts options.all_of(:foo)
  #   # => ["bar", "zoo"]
  #
  # A "file" option can be set. This config will be prefered over "default" options
  # but will defer to any available "user" specified options.
  #
  #   user_options    = { foo: "bar" }
  #   default_options = { rackup: "zoo.rb" }
  #   options = UserFileDefaultOptions.new(user_options, default_options)
  #   options.file_options[:rackup] = "sup.rb"
  #   puts options[:rackup]
  #   # => "sup.rb"
  #
  # The "default" options can be set via procs. These are resolved during runtime
  # via calls to `finalize_values`
  class UserFileDefaultOptions
    def initialize(user_options, default_options)
      @user_options    = user_options
      @file_options    = {}
      @default_options = default_options
    end

    attr_reader :user_options, :file_options, :default_options

    def [](key)
      return user_options[key]    if user_options.key?(key)
      return file_options[key]    if file_options.key?(key)
      return default_options[key] if default_options.key?(key)
    end

    def []=(key, value)
      user_options[key] = value
    end

    def fetch(key, default_value = nil)
      self[key] || default_value
    end

    def all_of(key)
      user    = user_options[key]
      file    = file_options[key]
      default = default_options[key]

      user    = [user]    unless user.is_a?(Array)
      file    = [file]    unless file.is_a?(Array)
      default = [default] unless default.is_a?(Array)

      user.compact!
      file.compact!
      default.compact!

      user + file + default
    end

    def finalize_values
      @default_options.each do |k,v|
        if v.respond_to? :call
          @default_options[k] = v.call
        end
      end
    end
  end

  # The main configuration class of Puma.
  #
  # It can be initialized with a set of "user" options and "default" options.
  # Defaults will be merged with `Configuration.puma_default_options`.
  #
  # This class works together with 2 main other classes the `UserFileDefaultOptions`
  # which stores configuration options in order so the precedence is that user
  # set configuration wins over "file" based configuration wins over "default"
  # configuration. These configurations are set via the `DSL` class. This
  # class powers the Puma config file syntax and does double duty as a configuration
  # DSL used by the `Puma::CLI` and Puma rack handler.
  #
  # It also handles loading plugins.
  #
  # > Note: `:port` and `:host` are not valid keys. By they time they make it to the
  #   configuration options they are expected to be incorporated into a `:binds` key.
  #   Under the hood the DSL maps `port` and `host` calls to `:binds`
  #
  #   config = Configuration.new({}) do |user_config, file_config, default_config|
  #     user_config.port 3003
  #   end
  #   config.load
  #   puts config.options[:port]
  #   # => 3003
  #
  # It is expected that `load` is called on the configuration instance after setting
  # config. This method expands any values in `config_file` and puts them into the
  # correct configuration option hash.
  #
  # Once all configuration is complete it is expected that `clamp` will be called
  # on the instance. This will expand any procs stored under "default" values. This
  # is done because an environment variable may have been modified while loading
  # configuration files.
  class Configuration
    include ConfigDefault

    def initialize(user_options={}, default_options = {}, &block)
      default_options = self.puma_default_options.merge(default_options)

      @options     = UserFileDefaultOptions.new(user_options, default_options)
      @plugins     = PluginLoader.new
      @user_dsl    = DSL.new(@options.user_options, self)
      @file_dsl    = DSL.new(@options.file_options, self)
      @default_dsl = DSL.new(@options.default_options, self)

      if block
        configure(&block)
      end
    end

    attr_reader :options, :plugins

    def configure
      yield @user_dsl, @file_dsl, @default_dsl
    ensure
      @user_dsl._offer_plugins
      @file_dsl._offer_plugins
      @default_dsl._offer_plugins
    end

    def initialize_copy(other)
      @conf        = nil
      @cli_options = nil
      @options     = @options.dup
    end

    def flatten
      dup.flatten!
    end

    def flatten!
      @options = @options.flatten
      self
    end

    def puma_default_options
      {
        :min_threads => 0,
        :max_threads => 16,
        :log_requests => false,
        :debug => false,
        :binds => ["tcp://#{DefaultTCPHost}:#{DefaultTCPPort}"],
        :workers => 0,
        :daemon => false,
        :mode => :http,
        :worker_timeout => DefaultWorkerTimeout,
        :worker_boot_timeout => DefaultWorkerTimeout,
        :worker_shutdown_timeout => DefaultWorkerShutdownTimeout,
        :remote_address => :socket,
        :tag => method(:infer_tag),
        :environment => -> { ENV['RACK_ENV'] || "development" },
        :rackup => DefaultRackup,
        :logger => STDOUT,
        :persistent_timeout => Const::PERSISTENT_TIMEOUT,
        :first_data_timeout => Const::FIRST_DATA_TIMEOUT
      }
    end

    def load
      config_files.each { |config_file| @file_dsl._load_from(config_file) }

      @options
    end

    def config_files
      files = @options.all_of(:config_files)

      return [] if files == ['-']
      return files if files.any?

      first_default_file = %W(config/puma/#{environment_str}.rb config/puma.rb).find do |f|
        File.exist?(f)
      end

      [first_default_file]
    end

    # Call once all configuration (included from rackup files)
    # is loaded to flesh out any defaults
    def clamp
      @options.finalize_values
    end

    # Injects the Configuration object into the env
    class ConfigMiddleware
      def initialize(config, app)
        @config = config
        @app = app
      end

      def call(env)
        env[Const::PUMA_CONFIG] = @config
        @app.call(env)
      end
    end

    # Indicate if there is a properly configured app
    #
    def app_configured?
      @options[:app] || File.exist?(rackup)
    end

    def rackup
      @options[:rackup]
    end

    # Load the specified rackup file, pull options from
    # the rackup file, and set @app.
    #
    def app
      found = options[:app] || load_rackup

      if @options[:mode] == :tcp
        require 'puma/tcp_logger'

        logger = @options[:logger]
        quiet = !@options[:log_requests]
        return TCPLogger.new(logger, found, quiet)
      end

      if @options[:log_requests]
        require 'puma/commonlogger'
        logger = @options[:logger]
        found = CommonLogger.new(found, logger)
      end

      ConfigMiddleware.new(self, found)
    end

    # Return which environment we're running in
    def environment
      @options[:environment]
    end

    def environment_str
      environment.respond_to?(:call) ? environment.call : environment
    end

    def load_plugin(name)
      @plugins.create name
    end

    def run_hooks(key, arg)
      @options.all_of(key).each { |b| b.call arg }
    end

    def self.temp_path
      require 'tmpdir'

      t = (Time.now.to_f * 1000).to_i
      "#{Dir.tmpdir}/puma-status-#{t}-#{$$}"
    end

    private

    def infer_tag
      File.basename(Dir.getwd)
    end

    # Load and use the normal Rack builder if we can, otherwise
    # fallback to our minimal version.
    def rack_builder
      # Load bundler now if we can so that we can pickup rack from
      # a Gemfile
      if ENV.key? 'PUMA_BUNDLER_PRUNED'
        begin
          require 'bundler/setup'
        rescue LoadError
        end
      end

      begin
        require 'rack'
        require 'rack/builder'
      rescue LoadError
        # ok, use builtin version
        return Puma::Rack::Builder
      else
        return ::Rack::Builder
      end
    end

    def load_rackup
      raise "Missing rackup file '#{rackup}'" unless File.exist?(rackup)

      rack_app, rack_options = rack_builder.parse_file(rackup)
      @options.file_options.merge!(rack_options)

      config_ru_binds = []
      rack_options.each do |k, v|
        config_ru_binds << v if k.to_s.start_with?("bind")
      end

      @options.file_options[:binds] = config_ru_binds unless config_ru_binds.empty?

      rack_app
    end

    def self.random_token
      begin
        require 'openssl'
      rescue LoadError
      end

      count = 16

      bytes = nil

      if defined? OpenSSL::Random
        bytes = OpenSSL::Random.random_bytes(count)
      elsif File.exist?("/dev/urandom")
        File.open('/dev/urandom') { |f| bytes = f.read(count) }
      end

      if bytes
        token = "".dup
        bytes.each_byte { |b| token << b.to_s(16) }
      else
        token = (0..count).to_a.map { rand(255).to_s(16) }.join
      end

      return token
    end
  end
end

require 'puma/dsl'
