module Puma
  # The methods that are available for use inside the config file.
  # These same methods are used in Puma cli and the rack handler
  # internally.
  #
  # Used manually (via CLI class):
  #
  #   config = Configuration.new({}) do |user_config|
  #     user_config.port 3001
  #   end
  #   config.load
  #
  #   puts config.options[:binds]
  #   "tcp://127.0.0.1:3001"
  #
  # Used to load file:
  #
  #   $ cat puma_config.rb
  #     port 3002
  #
  #   config = Configuration.new(config_file: "puma_config.rb")
  #   config.load
  #
  #   puts config.options[:binds]
  #   # => "tcp://127.0.0.1:3002"
  #
  # Detailed docs can be found in `examples/config.rb`
  class DSL
    include ConfigDefault

    def initialize(options, config)
      @config  = config
      @options = options

      @plugins = []
    end

    def _load_from(path)
      if path
        @path = path
        instance_eval(File.read(path), path, 1)
      end
    ensure
      _offer_plugins
    end

    def _offer_plugins
      @plugins.each do |o|
        if o.respond_to? :config
          @options.shift
          o.config self
        end
      end

      @plugins.clear
    end

    def inject(&blk)
      instance_eval(&blk)
    end

    def get(key,default=nil)
      @options[key.to_sym] || default
    end

    # Load the named plugin for use by this configuration
    #
    def plugin(name)
      @plugins << @config.load_plugin(name)
    end

    # Use +obj+ or +block+ as the Rack app. This allows a config file to
    # be the app itself.
    #
    def app(obj=nil, &block)
      obj ||= block

      raise "Provide either a #call'able or a block" unless obj

      @options[:app] = obj
    end

    # Start the Puma control rack app on +url+. This app can be communicated
    # with to control the main server.
    #
    def activate_control_app(url="auto", opts={})
      if url == "auto"
        path = Configuration.temp_path
        @options[:control_url] = "unix://#{path}"
        @options[:control_url_temp] = path
      else
        @options[:control_url] = url
      end

      if opts[:no_token]
        auth_token = :none
      else
        auth_token = opts[:auth_token]
        auth_token ||= Configuration.random_token
      end

      @options[:control_auth_token] = auth_token
      @options[:control_url_umask] = opts[:umask] if opts[:umask]
    end

    # Load additional configuration from a file
    # Files get loaded later via Configuration#load
    def load(file)
      @options[:config_files] ||= []
      @options[:config_files] << file
    end

    # Adds a binding for the server to +url+. tcp://, unix://, and ssl:// are the only accepted
    # protocols. Use query parameters within the url to specify options.
    #
    # @note multiple urls can be bound to, calling `bind` does not overwrite previous bindings.
    #
    # @example Explicitly the socket backlog depth (default is 1024)
    #   bind('unix:///var/run/puma.sock?backlog=2048')
    #
    # @example Set up ssl cert
    #   bind('ssl://127.0.0.1:9292?key=key.key&cert=cert.pem')
    #
    # @example Prefer low-latency over higher throughput (via `Socket::TCP_NODELAY`)
    #   bind('tcp://0.0.0.0:9292?low_latency=true')
    #
    # @example Set socket permissions
    #   bind('unix:///var/run/puma.sock?umask=0111')
    def bind(url)
      @options[:binds] ||= []
      @options[:binds] << url
    end

    def clear_binds!
      @options[:binds] = []
    end

    # Define the TCP port to bind to. Use +bind+ for more advanced options.
    #
    def port(port, host=nil)
      host ||= Configuration::DefaultTCPHost
      bind "tcp://#{host}:#{port}"
    end

    # Define how long persistent connections can be idle before puma closes
    # them
    #
    def persistent_timeout(seconds)
      @options[:persistent_timeout] = seconds
    end

    # Define how long the tcp socket stays open, if no data has been received
    #
    def first_data_timeout(seconds)
      @options[:first_data_timeout] = seconds
    end

    # Work around leaky apps that leave garbage in Thread locals
    # across requests
    #
    def clean_thread_locals(which=true)
      @options[:clean_thread_locals] = which
    end

    # Daemonize the server into the background. Highly suggest that
    # this be combined with +pidfile+ and +stdout_redirect+.
    def daemonize(which=true)
      @options[:daemon] = which
    end

    # When shutting down, drain the accept socket of pending
    # connections and proces them. This loops over the accept
    # socket until there are no more read events and then stops
    # looking and waits for the requests to finish.
    def drain_on_shutdown(which=true)
      @options[:drain_on_shutdown] = which
    end

    # Set the environment in which the Rack's app will run.
    def environment(environment)
      @options[:environment] = environment
    end

    # How long to wait for threads to stop when shutting them
    # down. Defaults to :forever. Specifying :immediately will cause
    # Puma to kill the threads immediately.  Otherwise the value
    # is the number of seconds to wait.
    #
    # Puma always waits a few seconds after killing a thread for it to try
    # to finish up it's work, even in :immediately mode.
    def force_shutdown_after(val=:forever)
      i = case val
          when :forever
            -1
          when :immediately
            0
          else
            Integer(val)
          end

      @options[:force_shutdown_after] = i
    end

    # Code to run before doing a restart. This code should
    # close logfiles, database connections, etc.
    #
    # This can be called multiple times to add code each time.
    #
    def on_restart(&block)
      @options[:on_restart] ||= []
      @options[:on_restart] << block
    end

    # Command to use to restart puma. This should be just how to
    # load puma itself (ie. 'ruby -Ilib bin/puma'), not the arguments
    # to puma, as those are the same as the original process.
    #
    def restart_command(cmd)
      @options[:restart_cmd] = cmd.to_s
    end

    # Store the pid of the server in the file at +path+.
    def pidfile(path)
      @options[:pidfile] = path.to_s
    end

    # Disable request logging.
    #
    def quiet(which=true)
      @options[:log_requests] = !which
    end

    # Enable request logging
    #
    def log_requests(which=true)
      @options[:log_requests] = which
    end

    # Show debugging info
    #
    def debug
      @options[:debug] = true
    end

    # Load +path+ as a rackup file.
    #
    def rackup(path)
      @options[:rackup] = path.to_s
    end

    # Run Puma in TCP mode
    #
    def tcp_mode!
      @options[:mode] = :tcp
    end

    def early_hints(answer=true)
      @options[:early_hints] = answer
    end

    # Redirect STDOUT and STDERR to files specified.
    def stdout_redirect(stdout=nil, stderr=nil, append=false)
      @options[:redirect_stdout] = stdout
      @options[:redirect_stderr] = stderr
      @options[:redirect_append] = append
    end

    # Configure +min+ to be the minimum number of threads to use to answer
    # requests and +max+ the maximum.
    #
    def threads(min, max)
      min = Integer(min)
      max = Integer(max)
      if min > max
        raise "The minimum (#{min}) number of threads must be less than or equal to the max (#{max})"
      end

      if max < 1
        raise "The maximum number of threads (#{max}) must be greater than 0"
      end

      @options[:min_threads] = min
      @options[:max_threads] = max
    end

    def ssl_bind(host, port, opts)
      verify = opts.fetch(:verify_mode, 'none')

      if defined?(JRUBY_VERSION)
        keystore_additions = "keystore=#{opts[:keystore]}&keystore-pass=#{opts[:keystore_pass]}"
        bind "ssl://#{host}:#{port}?cert=#{opts[:cert]}&key=#{opts[:key]}&#{keystore_additions}&verify_mode=#{verify}"
      else
        bind "ssl://#{host}:#{port}?cert=#{opts[:cert]}&key=#{opts[:key]}&verify_mode=#{verify}"
      end
    end

    # Use +path+ as the file to store the server info state. This is
    # used by pumactl to query and control the server.
    #
    def state_path(path)
      @options[:state] = path.to_s
    end

    # *Cluster mode only* How many worker processes to run.
    #
    def workers(count)
      @options[:workers] = count.to_i
    end

    # *Cluster mode only* Code to run immediately before master process
    # forks workers (once on boot). These hooks can block if necessary
    # to wait for background operations unknown to puma to finish before
    # the process terminates.
    # This can be used to close any connections to remote servers (database, redis, ...)
    # that were opened when preloading the code
    #
    # This can be called multiple times to add hooks.
    #
    def before_fork(&block)
      @options[:before_fork] ||= []
      @options[:before_fork] << block
    end

    # *Cluster mode only* Code to run in a worker when it boots to setup
    # the process before booting the app.
    #
    # This can be called multiple times to add hooks.
    #
    def on_worker_boot(&block)
      @options[:before_worker_boot] ||= []
      @options[:before_worker_boot] << block
    end

    # *Cluster mode only* Code to run immediately before a worker shuts
    # down (after it has finished processing HTTP requests). These hooks
    # can block if necessary to wait for background operations unknown
    # to puma to finish before the process terminates.
    #
    # This can be called multiple times to add hooks.
    #
    def on_worker_shutdown(&block)
      @options[:before_worker_shutdown] ||= []
      @options[:before_worker_shutdown] << block
    end

    # *Cluster mode only* Code to run in the master when it is
    # about to create the worker by forking itself.
    #
    # This can be called multiple times to add hooks.
    #
    def on_worker_fork(&block)
      @options[:before_worker_fork] ||= []
      @options[:before_worker_fork] << block
    end

    # *Cluster mode only* Code to run in the master after it starts
    # a worker.
    #
    # This can be called multiple times to add hooks.
    #
    def after_worker_fork(&block)
      @options[:after_worker_fork] ||= []
      @options[:after_worker_fork] = block
    end

    alias_method :after_worker_boot, :after_worker_fork

    # The directory to operate out of.
    def directory(dir)
      @options[:directory] = dir.to_s
    end

    # DEPRECATED: The directory to operate out of.
    def worker_directory(dir)
      $stderr.puts "worker_directory is deprecated. Please use `directory`"
      directory dir
    end

    # Run the app as a raw TCP app instead of an HTTP rack app
    def tcp_mode
      @options[:mode] = :tcp
    end

    # *Cluster mode only* Preload the application before starting
    # the workers and setting up the listen ports. This conflicts
    # with using the phased restart feature, you can't use both.
    #
    def preload_app!(answer=true)
      @options[:preload_app] = answer
    end

    # Use +obj+ or +block+ as the low level error handler. This allows a config file to
    # change the default error on the server.
    #
    def lowlevel_error_handler(obj=nil, &block)
      obj ||= block
      raise "Provide either a #call'able or a block" unless obj
      @options[:lowlevel_error_handler] = obj
    end

    # This option is used to allow your app and its gems to be
    # properly reloaded when not using preload.
    #
    # When set, if puma detects that it's been invoked in the
    # context of Bundler, it will cleanup the environment and
    # re-run itself outside the Bundler environment, but directly
    # using the files that Bundler has setup.
    #
    # This means that puma is now decoupled from your Bundler
    # context and when each worker loads, it will be loading a
    # new Bundler context and thus can float around as the release
    # dictates.
    def prune_bundler(answer=true)
      @options[:prune_bundler] = answer
    end

    # Additional text to display in process listing
    def tag(string)
      @options[:tag] = string.to_s
    end

    # *Cluster mode only* Set the timeout for workers in seconds
    # When set the master process will terminate any workers
    # that have not checked in within the given +timeout+.
    # This mitigates hung processes. Default value is 60 seconds.
    def worker_timeout(timeout)
      @options[:worker_timeout] = timeout
    end

    # *Cluster mode only* Set the timeout for workers to boot
    def worker_boot_timeout(timeout)
      @options[:worker_boot_timeout] = timeout
    end

    # *Cluster mode only* Set the timeout for worker shutdown
    def worker_shutdown_timeout(timeout)
      @options[:worker_shutdown_timeout] = timeout
    end

    # When set to true (the default), workers accept all requests
    # and queue them before passing them to the handlers.
    # When set to false, each worker process accepts exactly as
    # many requests as it is configured to simultaneously handle.
    #
    # Queueing requests generally improves performance. In some
    # cases, such as a single threaded application, it may be
    # better to ensure requests get balanced across workers.
    #
    # Note that setting this to false disables HTTP keepalive and
    # slow clients will occupy a handler thread while the request
    # is being sent. A reverse proxy, such as nginx, can handle
    # slow clients and queue requests before they reach puma.
    def queue_requests(answer=true)
      @options[:queue_requests] = answer
    end

    # When a shutdown is requested, the backtraces of all the
    # threads will be written to $stdout. This can help figure
    # out why shutdown is hanging.
    def shutdown_debug(val=true)
      @options[:shutdown_debug] = val
    end

    # Control how the remote address of the connection is set. This
    # is configurable because to calculate the true socket peer address
    # a kernel syscall is required which for very fast rack handlers
    # slows down the handling significantly.
    #
    # There are 4 possible values:
    #
    # * :socket (the default) - read the peername from the socket using the
    #           syscall. This is the normal behavior.
    # * :localhost - set the remote address to "127.0.0.1"
    # * header: http_header - set the remote address to the value of the
    #                          provided http header. For instance:
    #                          `set_remote_address header: "X-Real-IP"`.
    #                          Only the first word (as separated by spaces or comma)
    #                          is used, allowing headers such as X-Forwarded-For
    #                          to be used as well.
    # * Any string - this allows you to hardcode remote address to any value
    #                you wish. Because puma never uses this field anyway, it's
    #                format is entirely in your hands.
    def set_remote_address(val=:socket)
      case val
      when :socket
        @options[:remote_address] = val
      when :localhost
        @options[:remote_address] = :value
        @options[:remote_address_value] = "127.0.0.1".freeze
      when String
        @options[:remote_address] = :value
        @options[:remote_address_value] = val
      when Hash
        if hdr = val[:header]
          @options[:remote_address] = :header
          @options[:remote_address_header] = "HTTP_" + hdr.upcase.gsub("-", "_")
        else
          raise "Invalid value for set_remote_address - #{val.inspect}"
        end
      else
        raise "Invalid value for set_remote_address - #{val}"
      end
    end

  end
end
