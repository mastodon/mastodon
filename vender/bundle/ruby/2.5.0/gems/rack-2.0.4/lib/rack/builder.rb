module Rack
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
    def self.parse_file(config, opts = Server::Options.new)
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
        app = Object.const_get(::File.basename(config, '.rb').split('_').map(&:capitalize).join(''))
      end
      return app, options
    end

    def self.new_from_string(builder_script, file="(rackup)")
      eval "Rack::Builder.new {\n" + builder_script + "\n}.to_app",
        TOPLEVEL_BINDING, file, 0
    end

    def initialize(default_app = nil, &block)
      @use, @map, @run, @warmup = [], nil, default_app, nil
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
    #     end
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
      mapped = default_app ? {'/' => default_app} : {}
      mapping.each { |r,b| mapped[r] = self.class.new(default_app, &b).to_app }
      URLMap.new(mapped)
    end
  end
end
