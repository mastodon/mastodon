require 'optparse'
require 'uri'

require 'puma/configuration'
require 'puma/launcher'
require 'puma/const'
require 'puma/events'

module Puma
  class << self
    # The CLI exports its Puma::Configuration object here to allow
    # apps to pick it up. An app needs to use it conditionally though
    # since it is not set if the app is launched via another
    # mechanism than the CLI class.
    attr_accessor :cli_config
  end

  # Handles invoke a Puma::Server in a command line style.
  #
  class CLI
    KEYS_NOT_TO_PERSIST_IN_STATE = Launcher::KEYS_NOT_TO_PERSIST_IN_STATE

    # Create a new CLI object using +argv+ as the command line
    # arguments.
    #
    # +stdout+ and +stderr+ can be set to IO-like objects which
    # this object will report status on.
    #
    def initialize(argv, events=Events.stdio)
      @debug = false
      @argv = argv.dup

      @events = events

      @conf = nil

      @stdout = nil
      @stderr = nil
      @append = false

      @control_url = nil
      @control_options = {}

      setup_options

      begin
        @parser.parse! @argv

        if file = @argv.shift
          @conf.configure do |user_config, file_config|
            file_config.rackup file
          end
        end
      rescue UnsupportedOption
        exit 1
      end

      @conf.configure do |user_config, file_config|
        if @stdout || @stderr
          user_config.stdout_redirect @stdout, @stderr, @append
        end

        if @control_url
          user_config.activate_control_app @control_url, @control_options
        end
      end

      @launcher = Puma::Launcher.new(@conf, :events => @events, :argv => argv)
    end

    attr_reader :launcher

    # Parse the options, load the rackup, start the server and wait
    # for it to finish.
    #
    def run
      @launcher.run
    end

  private
    def unsupported(str)
      @events.error(str)
      raise UnsupportedOption
    end

    # Build the OptionParser object to handle the available options.
    #

    def setup_options
      @conf = Configuration.new do |user_config, file_config|
        @parser = OptionParser.new do |o|
          o.on "-b", "--bind URI", "URI to bind to (tcp://, unix://, ssl://)" do |arg|
            user_config.bind arg
          end

          o.on "-C", "--config PATH", "Load PATH as a config file" do |arg|
            file_config.load arg
          end

          o.on "--control URL", "The bind url to use for the control server",
            "Use 'auto' to use temp unix server" do |arg|
            if arg
              @control_url = arg
            elsif Puma.jruby?
              unsupported "No default url available on JRuby"
            end
          end

          o.on "--control-token TOKEN",
            "The token to use as authentication for the control server" do |arg|
            @control_options[:auth_token] = arg
          end

          o.on "-d", "--daemon", "Daemonize the server into the background" do
            user_config.daemonize
            user_config.quiet
          end

          o.on "--debug", "Log lowlevel debugging information" do
            user_config.debug
          end

          o.on "--dir DIR", "Change to DIR before starting" do |d|
            user_config.directory d
          end

          o.on "-e", "--environment ENVIRONMENT",
            "The environment to run the Rack app on (default development)" do |arg|
            user_config.environment arg
          end

          o.on "-I", "--include PATH", "Specify $LOAD_PATH directories" do |arg|
            $LOAD_PATH.unshift(*arg.split(':'))
          end

          o.on "-p", "--port PORT", "Define the TCP port to bind to",
            "Use -b for more advanced options" do |arg|
            user_config.bind "tcp://#{Configuration::DefaultTCPHost}:#{arg}"
          end

          o.on "--pidfile PATH", "Use PATH as a pidfile" do |arg|
            user_config.pidfile arg
          end

          o.on "--preload", "Preload the app. Cluster mode only" do
            user_config.preload_app!
          end

          o.on "--prune-bundler", "Prune out the bundler env if possible" do
            user_config.prune_bundler
          end

          o.on "-q", "--quiet", "Do not log requests internally (default true)" do
            user_config.quiet
          end

          o.on "-v", "--log-requests", "Log requests as they occur" do
            user_config.log_requests
          end

          o.on "-R", "--restart-cmd CMD",
            "The puma command to run during a hot restart",
            "Default: inferred" do |cmd|
            user_config.restart_command cmd
          end

          o.on "-S", "--state PATH", "Where to store the state details" do |arg|
            user_config.state_path arg
          end

          o.on '-t', '--threads INT', "min:max threads to use (default 0:16)" do |arg|
            min, max = arg.split(":")
            if max
              user_config.threads min, max
            else
              user_config.threads min, min
            end
          end

          o.on "--tcp-mode", "Run the app in raw TCP mode instead of HTTP mode" do
            user_config.tcp_mode!
          end

          o.on "--early-hints", "Enable early hints support" do
            user_config.early_hints
          end

          o.on "-V", "--version", "Print the version information" do
            puts "puma version #{Puma::Const::VERSION}"
            exit 0
          end

          o.on "-w", "--workers COUNT",
            "Activate cluster mode: How many worker processes to create" do |arg|
            user_config.workers arg
          end

          o.on "--tag NAME", "Additional text to display in process listing" do |arg|
            user_config.tag arg
          end

          o.on "--redirect-stdout FILE", "Redirect STDOUT to a specific file" do |arg|
            @stdout = arg.to_s
          end

          o.on "--redirect-stderr FILE", "Redirect STDERR to a specific file" do |arg|
            @stderr = arg.to_s
          end

          o.on "--[no-]redirect-append", "Append to redirected files" do |val|
            @append = val
          end

          o.banner = "puma <options> <rackup file>"

          o.on_tail "-h", "--help", "Show help" do
            $stdout.puts o
            exit 0
          end
        end
      end
    end
  end
end
