require 'optparse'
require 'fileutils'


module Rack

  class Server

    class Options
      def parse!(args)
        options = {}
        opt_parser = OptionParser.new("", 24, '  ') do |opts|
          opts.banner = "Usage: rackup [ruby options] [rack options] [rackup config]"

          opts.separator ""
          opts.separator "Ruby options:"

          lineno = 1
          opts.on("-e", "--eval LINE", "evaluate a LINE of code") { |line|
            eval line, TOPLEVEL_BINDING, "-e", lineno
            lineno += 1
          }

          opts.on("-b", "--builder BUILDER_LINE", "evaluate a BUILDER_LINE of code as a builder script") { |line|
            options[:builder] = line
          }

          opts.on("-d", "--debug", "set debugging flags (set $DEBUG to true)") {
            options[:debug] = true
          }
          opts.on("-w", "--warn", "turn warnings on for your script") {
            options[:warn] = true
          }
          opts.on("-q", "--quiet", "turn off logging") {
            options[:quiet] = true
          }

          opts.on("-I", "--include PATH",
                  "specify $LOAD_PATH (may be used more than once)") { |path|
            (options[:include] ||= []).concat(path.split(":"))
          }

          opts.on("-r", "--require LIBRARY",
                  "require the library, before executing your script") { |library|
            options[:require] = library
          }

          opts.separator ""
          opts.separator "Rack options:"
          opts.on("-s", "--server SERVER", "serve using SERVER (thin/puma/webrick/mongrel)") { |s|
            options[:server] = s
          }

          opts.on("-o", "--host HOST", "listen on HOST (default: localhost)") { |host|
            options[:Host] = host
          }

          opts.on("-p", "--port PORT", "use PORT (default: 9292)") { |port|
            options[:Port] = port
          }

          opts.on("-O", "--option NAME[=VALUE]", "pass VALUE to the server as option NAME. If no VALUE, sets it to true. Run '#{$0} -s SERVER -h' to get a list of options for SERVER") { |name|
            name, value = name.split('=', 2)
            value = true if value.nil?
            options[name.to_sym] = value
          }

          opts.on("-E", "--env ENVIRONMENT", "use ENVIRONMENT for defaults (default: development)") { |e|
            options[:environment] = e
          }

          opts.on("-D", "--daemonize", "run daemonized in the background") { |d|
            options[:daemonize] = d ? true : false
          }

          opts.on("-P", "--pid FILE", "file to store PID") { |f|
            options[:pid] = ::File.expand_path(f)
          }

          opts.separator ""
          opts.separator "Common options:"

          opts.on_tail("-h", "-?", "--help", "Show this message") do
            puts opts
            puts handler_opts(options)

            exit
          end

          opts.on_tail("--version", "Show version") do
            puts "Rack #{Rack.version} (Release: #{Rack.release})"
            exit
          end
        end

        begin
          opt_parser.parse! args
        rescue OptionParser::InvalidOption => e
          warn e.message
          abort opt_parser.to_s
        end

        options[:config] = args.last if args.last && !args.last.empty?
        options
      end

      def handler_opts(options)
        begin
          info = []
          server = Rack::Handler.get(options[:server]) || Rack::Handler.default
          if server && server.respond_to?(:valid_options)
            info << ""
            info << "Server-specific options for #{server.name}:"

            has_options = false
            server.valid_options.each do |name, description|
              next if name.to_s.match(/^(Host|Port)[^a-zA-Z]/) # ignore handler's host and port options, we do our own.
              info << "  -O %-21s %s" % [name, description]
              has_options = true
            end
            return "" if !has_options
          end
          info.join("\n")
        rescue NameError
          return "Warning: Could not find handler specified (#{options[:server] || 'default'}) to determine handler-specific options"
        end
      end
    end

    # Start a new rack server (like running rackup). This will parse ARGV and
    # provide standard ARGV rackup options, defaulting to load 'config.ru'.
    #
    # Providing an options hash will prevent ARGV parsing and will not include
    # any default options.
    #
    # This method can be used to very easily launch a CGI application, for
    # example:
    #
    #  Rack::Server.start(
    #    :app => lambda do |e|
    #      [200, {'Content-Type' => 'text/html'}, ['hello world']]
    #    end,
    #    :server => 'cgi'
    #  )
    #
    # Further options available here are documented on Rack::Server#initialize
    def self.start(options = nil)
      new(options).start
    end

    attr_writer :options

    # Options may include:
    # * :app
    #     a rack application to run (overrides :config)
    # * :config
    #     a rackup configuration file path to load (.ru)
    # * :environment
    #     this selects the middleware that will be wrapped around
    #     your application. Default options available are:
    #       - development: CommonLogger, ShowExceptions, and Lint
    #       - deployment: CommonLogger
    #       - none: no extra middleware
    #     note: when the server is a cgi server, CommonLogger is not included.
    # * :server
    #     choose a specific Rack::Handler, e.g. cgi, fcgi, webrick
    # * :daemonize
    #     if true, the server will daemonize itself (fork, detach, etc)
    # * :pid
    #     path to write a pid file after daemonize
    # * :Host
    #     the host address to bind to (used by supporting Rack::Handler)
    # * :Port
    #     the port to bind to (used by supporting Rack::Handler)
    # * :AccessLog
    #     webrick access log options (or supporting Rack::Handler)
    # * :debug
    #     turn on debug output ($DEBUG = true)
    # * :warn
    #     turn on warnings ($-w = true)
    # * :include
    #     add given paths to $LOAD_PATH
    # * :require
    #     require the given libraries
    def initialize(options = nil)
      @ignore_options = []

      if options
        @use_default_options = false
        @options = options
        @app = options[:app] if options[:app]
      else
        argv = defined?(SPEC_ARGV) ? SPEC_ARGV : ARGV
        @use_default_options = true
        @options = parse_options(argv)
      end
    end

    def options
      merged_options = @use_default_options ? default_options.merge(@options) : @options
      merged_options.reject { |k, v| @ignore_options.include?(k) }
    end

    def default_options
      environment  = ENV['RACK_ENV'] || 'development'
      default_host = environment == 'development' ? 'localhost' : '0.0.0.0'

      {
        :environment => environment,
        :pid         => nil,
        :Port        => 9292,
        :Host        => default_host,
        :AccessLog   => [],
        :config      => "config.ru"
      }
    end

    def app
      @app ||= options[:builder] ? build_app_from_string : build_app_and_options_from_config
    end

    class << self
      def logging_middleware
        lambda { |server|
          server.server.name =~ /CGI/ || server.options[:quiet] ? nil : [Rack::CommonLogger, $stderr]
        }
      end

      def default_middleware_by_environment
        m = Hash.new {|h,k| h[k] = []}
        m["deployment"] = [
          [Rack::ContentLength],
          [Rack::Chunked],
          logging_middleware,
          [Rack::TempfileReaper]
        ]
        m["development"] = [
          [Rack::ContentLength],
          [Rack::Chunked],
          logging_middleware,
          [Rack::ShowExceptions],
          [Rack::Lint],
          [Rack::TempfileReaper]
        ]

        m
      end

      def middleware
        default_middleware_by_environment
      end
    end

    def middleware
      self.class.middleware
    end

    def start &blk
      if options[:warn]
        $-w = true
      end

      if includes = options[:include]
        $LOAD_PATH.unshift(*includes)
      end

      if library = options[:require]
        require library
      end

      if options[:debug]
        $DEBUG = true
        require 'pp'
        p options[:server]
        pp wrapped_app
        pp app
      end

      check_pid! if options[:pid]

      # Touch the wrapped app, so that the config.ru is loaded before
      # daemonization (i.e. before chdir, etc).
      wrapped_app

      daemonize_app if options[:daemonize]

      write_pid if options[:pid]

      trap(:INT) do
        if server.respond_to?(:shutdown)
          server.shutdown
        else
          exit
        end
      end

      server.run wrapped_app, options, &blk
    end

    def server
      @_server ||= Rack::Handler.get(options[:server])

      unless @_server
        @_server = Rack::Handler.default

        # We already speak FastCGI
        @ignore_options = [:File, :Port] if @_server.to_s == 'Rack::Handler::FastCGI'
      end

      @_server
    end

    private
      def build_app_and_options_from_config
        if !::File.exist? options[:config]
          abort "configuration #{options[:config]} not found"
        end

        app, options = Rack::Builder.parse_file(self.options[:config], opt_parser)
        @options.merge!(options) { |key, old, new| old }
        app
      end

      def build_app_from_string
        Rack::Builder.new_from_string(self.options[:builder])
      end

      def parse_options(args)
        # Don't evaluate CGI ISINDEX parameters.
        # http://www.meb.uni-bonn.de/docs/cgi/cl.html
        args.clear if ENV.include?(REQUEST_METHOD)

        @options = opt_parser.parse!(args)
        @options[:config] = ::File.expand_path(options[:config])
        ENV["RACK_ENV"] = options[:environment]
        @options
      end

      def opt_parser
        Options.new
      end

      def build_app(app)
        middleware[options[:environment]].reverse_each do |middleware|
          middleware = middleware.call(self) if middleware.respond_to?(:call)
          next unless middleware
          klass, *args = middleware
          app = klass.new(app, *args)
        end
        app
      end

      def wrapped_app
        @wrapped_app ||= build_app app
      end

      def daemonize_app
        Process.daemon
      end

      def write_pid
        ::File.open(options[:pid], ::File::CREAT | ::File::EXCL | ::File::WRONLY ){ |f| f.write("#{Process.pid}") }
        at_exit { ::FileUtils.rm_f(options[:pid]) }
      rescue Errno::EEXIST
        check_pid!
        retry
      end

      def check_pid!
        case pidfile_process_status
        when :running, :not_owned
          $stderr.puts "A server is already running. Check #{options[:pid]}."
          exit(1)
        when :dead
          ::File.delete(options[:pid])
        end
      end

      def pidfile_process_status
        return :exited unless ::File.exist?(options[:pid])

        pid = ::File.read(options[:pid]).to_i
        return :dead if pid == 0

        Process.kill(0, pid)
        :running
      rescue Errno::ESRCH
        :dead
      rescue Errno::EPERM
        :not_owned
      end

  end

end
