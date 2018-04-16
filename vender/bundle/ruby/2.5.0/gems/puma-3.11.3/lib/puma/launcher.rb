require 'puma/events'
require 'puma/detect'

require 'puma/cluster'
require 'puma/single'

require 'puma/const'

require 'puma/binder'

module Puma
  # Puma::Launcher is the single entry point for starting a Puma server based on user
  # configuration. It is responsible for taking user supplied arguments and resolving them
  # with configuration in `config/puma.rb` or `config/puma/<env>.rb`.
  #
  # It is responsible for either launching a cluster of Puma workers or a single
  # puma server.
  class Launcher
    KEYS_NOT_TO_PERSIST_IN_STATE = [
       :logger, :lowlevel_error_handler,
       :before_worker_shutdown, :before_worker_boot, :before_worker_fork,
       :after_worker_boot, :before_fork, :on_restart
     ]
    # Returns an instance of Launcher
    #
    # +conf+ A Puma::Configuration object indicating how to run the server.
    #
    # +launcher_args+ A Hash that currently has one required key `:events`,
    # this is expected to hold an object similar to an `Puma::Events.stdio`,
    # this object will be responsible for broadcasting Puma's internal state
    # to a logging destination. An optional key `:argv` can be supplied,
    # this should be an array of strings, these arguments are re-used when
    # restarting the puma server.
    #
    # Examples:
    #
    #   conf = Puma::Configuration.new do |user_config|
    #     user_config.threads 1, 10
    #     user_config.app do |env|
    #       [200, {}, ["hello world"]]
    #     end
    #   end
    #   Puma::Launcher.new(conf, events: Puma::Events.stdio).run
    def initialize(conf, launcher_args={})
      @runner        = nil
      @events        = launcher_args[:events] || Events::DEFAULT
      @argv          = launcher_args[:argv] || []
      @original_argv = @argv.dup
      @config        = conf

      @binder        = Binder.new(@events)
      @binder.import_from_env

      @environment = conf.environment

      # Advertise the Configuration
      Puma.cli_config = @config if defined?(Puma.cli_config)

      @config.load

      @options = @config.options
      @config.clamp

      generate_restart_data

      if clustered? && (Puma.jruby? || Puma.windows?)
        unsupported 'worker mode not supported on JRuby or Windows'
      end

      if @options[:daemon] && Puma.windows?
        unsupported 'daemon mode not supported on Windows'
      end

      Dir.chdir(@restart_dir)

      prune_bundler if prune_bundler?

      @environment = @options[:environment] if @options[:environment]
      set_rack_environment

      if clustered?
        @events.formatter = Events::PidFormatter.new
        @options[:logger] = @events

        @runner = Cluster.new(self, @events)
      else
        @runner = Single.new(self, @events)
      end

      @status = :run
    end

    attr_reader :binder, :events, :config, :options, :restart_dir

    # Return stats about the server
    def stats
      @runner.stats
    end

    # Write a state file that can be used by pumactl to control
    # the server
    def write_state
      write_pid

      path = @options[:state]
      return unless path

      require 'puma/state_file'

      sf = StateFile.new
      sf.pid = Process.pid
      sf.control_url = @options[:control_url]
      sf.control_auth_token = @options[:control_auth_token]

      sf.save path
    end

    # Delete the configured pidfile
    def delete_pidfile
      path = @options[:pidfile]
      File.unlink(path) if path && File.exist?(path)
    end

    # If configured, write the pid of the current process out
    # to a file.
    def write_pid
      path = @options[:pidfile]
      return unless path

      File.open(path, 'w') { |f| f.puts Process.pid }
      cur = Process.pid
      at_exit do
        delete_pidfile if cur == Process.pid
      end
    end

    # Begin async shutdown of the server
    def halt
      @status = :halt
      @runner.halt
    end

    # Begin async shutdown of the server gracefully
    def stop
      @status = :stop
      @runner.stop
    end

    # Begin async restart of the server
    def restart
      @status = :restart
      @runner.restart
    end

    # Begin a phased restart if supported
    def phased_restart
      unless @runner.respond_to?(:phased_restart) and @runner.phased_restart
        log "* phased-restart called but not available, restarting normally."
        return restart
      end
      true
    end

    # Run the server. This blocks until the server is stopped
    def run
      previous_env =
        if defined?(Bundler)
          env = Bundler::ORIGINAL_ENV.dup
          # add -rbundler/setup so we load from Gemfile when restarting
          bundle = "-rbundler/setup"
          env["RUBYOPT"] = [env["RUBYOPT"], bundle].join(" ").lstrip unless env["RUBYOPT"].to_s.include?(bundle)
          env
        else
          ENV.to_h
        end

      @config.clamp

      @config.plugins.fire_starts self

      setup_signals
      set_process_title
      @runner.run

      case @status
      when :halt
        log "* Stopping immediately!"
      when :run, :stop
        graceful_stop
      when :restart
        log "* Restarting..."
        ENV.replace(previous_env)
        @runner.before_restart
        restart!
      when :exit
        # nothing
      end
    end

    # Return which tcp port the launcher is using, if it's using TCP
    def connected_port
      @binder.connected_port
    end

    def restart_args
      cmd = @options[:restart_cmd]
      if cmd
        cmd.split(' ') + @original_argv
      else
        @restart_argv
      end
    end

    private

    def reload_worker_directory
      @runner.reload_worker_directory if @runner.respond_to?(:reload_worker_directory)
    end

    def restart!
      @config.run_hooks :on_restart, self

      if Puma.jruby?
        close_binder_listeners

        require 'puma/jruby_restart'
        JRubyRestart.chdir_exec(@restart_dir, restart_args)
      elsif Puma.windows?
        close_binder_listeners

        argv = restart_args
        Dir.chdir(@restart_dir)
        Kernel.exec(*argv)
      else
        redirects = {:close_others => true}
        @binder.listeners.each_with_index do |(l, io), i|
          ENV["PUMA_INHERIT_#{i}"] = "#{io.to_i}:#{l}"
          redirects[io.to_i] = io.to_i
        end

        argv = restart_args
        Dir.chdir(@restart_dir)
        argv += [redirects] if RUBY_VERSION >= '1.9'
        Kernel.exec(*argv)
      end
    end

    def prune_bundler
      return unless defined?(Bundler)
      puma = Bundler.rubygems.loaded_specs("puma")
      dirs = puma.require_paths.map { |x| File.join(puma.full_gem_path, x) }
      puma_lib_dir = dirs.detect { |x| File.exist? File.join(x, '../bin/puma-wild') }

      unless puma_lib_dir
        log "! Unable to prune Bundler environment, continuing"
        return
      end

      deps = puma.runtime_dependencies.map do |d|
        spec = Bundler.rubygems.loaded_specs(d.name)
        "#{d.name}:#{spec.version.to_s}"
      end

      log '* Pruning Bundler environment'
      home = ENV['GEM_HOME']
      Bundler.with_clean_env do
        ENV['GEM_HOME'] = home
        ENV['PUMA_BUNDLER_PRUNED'] = '1'
        wild = File.expand_path(File.join(puma_lib_dir, "../bin/puma-wild"))
        args = [Gem.ruby, wild, '-I', dirs.join(':'), deps.join(',')] + @original_argv
        # Ruby 2.0+ defaults to true which breaks socket activation
        args += [{:close_others => false}] if RUBY_VERSION >= '2.0'
        Kernel.exec(*args)
      end
    end

    def log(str)
      @events.log str
    end

    def clustered?
      (@options[:workers] || 0) > 0
    end

    def unsupported(str)
      @events.error(str)
      raise UnsupportedOption
    end

    def graceful_stop
      @runner.stop_blocked
      log "=== puma shutdown: #{Time.now} ==="
      log "- Goodbye!"
    end

    def set_process_title
      Process.respond_to?(:setproctitle) ? Process.setproctitle(title) : $0 = title
    end

    def title
      buffer  = "puma #{Puma::Const::VERSION} (#{@options[:binds].join(',')})"
      buffer += " [#{@options[:tag]}]" if @options[:tag] && !@options[:tag].empty?
      buffer
    end

    def set_rack_environment
      @options[:environment] = environment
      ENV['RACK_ENV'] = environment
    end

    def environment
      @environment
    end

    def prune_bundler?
      @options[:prune_bundler] && clustered? && !@options[:preload_app]
    end

    def close_binder_listeners
      @binder.listeners.each do |l, io|
        io.close
        uri = URI.parse(l)
        next unless uri.scheme == 'unix'
        File.unlink("#{uri.host}#{uri.path}")
      end
    end


    def generate_restart_data
      if dir = @options[:directory]
        @restart_dir = dir

      elsif Puma.windows?
        # I guess the value of PWD is garbage on windows so don't bother
        # using it.
        @restart_dir = Dir.pwd

        # Use the same trick as unicorn, namely favor PWD because
        # it will contain an unresolved symlink, useful for when
        # the pwd is /data/releases/current.
      elsif dir = ENV['PWD']
        s_env = File.stat(dir)
        s_pwd = File.stat(Dir.pwd)

        if s_env.ino == s_pwd.ino and (Puma.jruby? or s_env.dev == s_pwd.dev)
          @restart_dir = dir
        end
      end

      @restart_dir ||= Dir.pwd

      # if $0 is a file in the current directory, then restart
      # it the same, otherwise add -S on there because it was
      # picked up in PATH.
      #
      if File.exist?($0)
        arg0 = [Gem.ruby, $0]
      else
        arg0 = [Gem.ruby, "-S", $0]
      end

      # Detect and reinject -Ilib from the command line, used for testing without bundler
      # cruby has an expanded path, jruby has just "lib"
      lib = File.expand_path "lib"
      arg0[1,0] = ["-I", lib] if [lib, "lib"].include?($LOAD_PATH[0])

      if defined? Puma::WILD_ARGS
        @restart_argv = arg0 + Puma::WILD_ARGS + @original_argv
      else
        @restart_argv = arg0 + @original_argv
      end
    end

    def setup_signals
      begin
        Signal.trap "SIGUSR2" do
          restart
        end
      rescue Exception
        log "*** SIGUSR2 not implemented, signal based restart unavailable!"
      end

      unless Puma.jruby?
        begin
          Signal.trap "SIGUSR1" do
            phased_restart
          end
        rescue Exception
          log "*** SIGUSR1 not implemented, signal based restart unavailable!"
        end
      end

      begin
        Signal.trap "SIGTERM" do
          graceful_stop

          raise SignalException, "SIGTERM"
        end
      rescue Exception
        log "*** SIGTERM not implemented, signal based gracefully stopping unavailable!"
      end

      begin
        Signal.trap "SIGINT" do
          if Puma.jruby?
            @status = :exit
            graceful_stop
            exit
          end

          stop
        end
      rescue Exception
        log "*** SIGINT not implemented, signal based gracefully stopping unavailable!"
      end

      begin
        Signal.trap "SIGHUP" do
          if @runner.redirected_io?
            @runner.redirect_io
          else
            stop
          end
        end
      rescue Exception
        log "*** SIGHUP not implemented, signal based logs reopening unavailable!"
      end
    end
  end
end
