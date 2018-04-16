module Puma
end

module Puma::Rack
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

      options[:config] = args.last if args.last
      options
    end

    def handler_opts(options)
      begin
        info = []
        server = Rack::Handler.get(options[:server]) || Rack::Handler.default(options)
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

  # Rack::Builder implements a small DSL to iteratively construct Rack
  # applications.
  #
  # Example:
  #
  #  require 'rack/lobster'
  #  app = Rack::Builder.new do
  #    use Rack::CommonLogger
  #    use Rack::ShowExceptions
  #    map "/lobster" do
  #      use Rack::Lint
  #      run Rack::Lobster.new
  #    end
  #  end
  #
  #  run app
  #
  # Or
  #
  #  app = Rack::Builder.app do
  #    use Rack::CommonLogger
  #    run lambda { |env| [200, {'Content-Type' => 'text/plain'}, ['OK']] }
  #  end
  #
  #  run app
  #
  # +use+ adds middleware to the stack, +run+ dispatches to an application.
  # You can use +map+ to construct a Rack::URLMap in a convenient way.

  class Builder
    def self.parse_file(config, opts = Options.new)
      options = {}
      if config =~ /\.ru$/
        cfgfile = ::File.read(config)
        if cfgfile[/^#\\(.*)/] && opts
          options = opts.parse! $1.split(/\s+/)
        end
        cfgfile.sub!(/^__END__\n.*\Z/m, '')
        app = new_from_string cfgfile, config
      else
        require config
        app = Object.const_get(::File.basename(config, '.rb').capitalize)
      end
      return app, options
    end

    def self.new_from_string(builder_script, file="(rackup)")
      eval "Puma::Rack::Builder.new {\n" + builder_script + "\n}.to_app",
        TOPLEVEL_BINDING, file, 0
    end

    def initialize(default_app = nil,&block)
      @use, @map, @run, @warmup = [], nil, default_app, nil

      # Conditionally load rack now, so that any rack middlewares,
      # etc are available.
      begin
        require 'rack'
      rescue LoadError
      end

      instance_eval(&block) if block_given?
    end

    def self.app(default_app = nil, &block)
      self.new(default_app, &block).to_app
    end

    # Specifies middleware to use in a stack.
    #
    #   class Middleware
    #     def initialize(app)
    #       @app = app
    #     end
    #
    #     def call(env)
    #       env["rack.some_header"] = "setting an example"
    #       @app.call(env)
    #     end
    #   end
    #
    #   use Middleware
    #   run lambda { |env| [200, { "Content-Type" => "text/plain" }, ["OK"]] }
    #
    # All requests through to this application will first be processed by the middleware class.
    # The +call+ method in this example sets an additional environment key which then can be
    # referenced in the application if required.
    def use(middleware, *args, &block)
      if @map
        mapping, @map = @map, nil
        @use << proc { |app| generate_map app, mapping }
      end
      @use << proc { |app| middleware.new(app, *args, &block) }
    end

    # Takes an argument that is an object that responds to #call and returns a Rack response.
    # The simplest form of this is a lambda object:
    #
    #   run lambda { |env| [200, { "Content-Type" => "text/plain" }, ["OK"]] }
    #
    # However this could also be a class:
    #
    #   class Heartbeat
    #     def self.call(env)
    #      [200, { "Content-Type" => "text/plain" }, ["OK"]]
    #    end
    #   end
    #
    #   run Heartbeat
    def run(app)
      @run = app
    end

    # Takes a lambda or block that is used to warm-up the application.
    #
    #   warmup do |app|
    #     client = Rack::MockRequest.new(app)
    #     client.get('/')
    #   end
    #
    #   use SomeMiddleware
    #   run MyApp
    def warmup(prc=nil, &block)
      @warmup = prc || block
    end

    # Creates a route within the application.
    #
    #   Rack::Builder.app do
    #     map '/' do
    #       run Heartbeat
    #     end
    #   end
    #
    # The +use+ method can also be used here to specify middleware to run under a specific path:
    #
    #   Rack::Builder.app do
    #     map '/' do
    #       use Middleware
    #       run Heartbeat
    #     end
    #   end
    #
    # This example includes a piece of middleware which will run before requests hit +Heartbeat+.
    #
    def map(path, &block)
      @map ||= {}
      @map[path] = block
    end

    def to_app
      app = @map ? generate_map(@run, @map) : @run
      fail "missing run or map statement" unless app
      app = @use.reverse.inject(app) { |a,e| e[a] }
      @warmup.call(app) if @warmup
      app
    end

    def call(env)
      to_app.call(env)
    end

    private

    def generate_map(default_app, mapping)
      require 'puma/rack/urlmap'

      mapped = default_app ? {'/' => default_app} : {}
      mapping.each { |r,b| mapped[r] = self.class.new(default_app, &b).to_app }
      URLMap.new(mapped)
    end
  end
end
