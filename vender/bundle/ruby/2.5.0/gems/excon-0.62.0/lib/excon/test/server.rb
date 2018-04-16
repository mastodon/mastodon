require 'open4'
require 'excon'
require 'excon/test/plugin/server/webrick'
require 'excon/test/plugin/server/unicorn'
require 'excon/test/plugin/server/puma'
require 'excon/test/plugin/server/exec'


module Excon
  module Test
    class Server
      attr_accessor :app, :server, :bind, :pid, :read, :write, :error, :started_at, :timeout

      # Methods that must be implemented by a plugin
      INSTANCE_REQUIRES = [:start]
      Excon.defaults.merge!(
        connect_timeout: 5,
        read_timeout: 5,
        write_timeout: 5
      )

      def initialize(args)
        # TODO: Validate these args
        @server = args.keys.first
        @app = args[server]
        args[:bind] ||= 'tcp://127.0.0.1:9292'
        @bind = URI.parse(args[:bind])
        @is_unix_socket = (@bind.scheme == 'unix')
        @bind.host = @bind.host.gsub(/[\[\]]/, '') unless @is_unix_socket
        if args[:timeout]
          @timeout = args[:timeout]
        else
          @timeout = 20
        end
        name = @server.to_s.split('_').collect(&:capitalize).join
        plug = nested_const_get("Excon::Test::Plugin::Server::#{name}")
        self.extend plug
        check_implementation(plug)
      end

      def open_process(*args)
        if RUBY_PLATFORM == 'java'
          @pid, @write, @read, @error = IO.popen4(*args)
        else
          GC.disable if RUBY_VERSION < '1.9'
          @pid, @write, @read, @error = Open4.popen4(*args)
        end
        @started_at = Time.now
      end

      def elapsed_time
        Time.now - started_at
      end

      def stop
        if RUBY_PLATFORM == 'java'
          Process.kill('USR1', pid)
        else
          Process.kill(9, pid)
          GC.enable if RUBY_VERSION < '1.9'
          Process.wait(pid)
        end

        if @is_unix_socket
          socket = @bind.path
          File.delete(socket) if File.exist?(socket)
        end

        # TODO: Ensure process is really dead
        dump_errors
        true
      end
      def dump_errors
        lines = error.read.split($/)
        while line = lines.shift
          case line
            when /(ERROR|Error)/
              unless line =~ /(null cert chain|did not return a certificate|SSL_read:: internal error)/
                in_err = true
                puts
              end
            when /^(127|localhost)/
              in_err = false
            end
          puts line if in_err
        end
      end

      private

      def nested_const_get(namespace)
        namespace.split('::').inject(Object) do |mod, klass|
          mod.const_get(klass)
        end
      end

      def check_implementation(plug)
        INSTANCE_REQUIRES.each do |m|
          unless self.respond_to? m
            raise "FATAL: #{plug} does not implement ##{m}"
          end
        end
      end
    end
  end
end
