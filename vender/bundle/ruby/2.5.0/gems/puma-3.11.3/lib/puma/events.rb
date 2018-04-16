require 'puma/const'
require "puma/null_io"
require 'stringio'

module Puma
  # The default implement of an event sink object used by Server
  # for when certain kinds of events occur in the life of the server.
  #
  # The methods available are the events that the Server fires.
  #
  class Events
    class DefaultFormatter
      def call(str)
        str
      end
    end

    class PidFormatter
      def call(str)
        "[#{$$}] #{str}"
      end
    end

    include Const

    # Create an Events object that prints to +stdout+ and +stderr+.
    #
    def initialize(stdout, stderr)
      @formatter = DefaultFormatter.new
      @stdout = stdout
      @stderr = stderr

      @stdout.sync = true
      @stderr.sync = true

      @debug = ENV.key? 'PUMA_DEBUG'

      @hooks = Hash.new { |h,k| h[k] = [] }
    end

    attr_reader :stdout, :stderr
    attr_accessor :formatter

    # Fire callbacks for the named hook
    #
    def fire(hook, *args)
      @hooks[hook].each { |t| t.call(*args) }
    end

    # Register a callback for a given hook
    #
    def register(hook, obj=nil, &blk)
      if obj and blk
        raise "Specify either an object or a block, not both"
      end

      h = obj || blk

      @hooks[hook] << h

      h
    end

    # Write +str+ to +@stdout+
    #
    def log(str)
      @stdout.puts format(str)
    end

    def write(str)
      @stdout.write format(str)
    end

    def debug(str)
      log("% #{str}") if @debug
    end

    # Write +str+ to +@stderr+
    #
    def error(str)
      @stderr.puts format("ERROR: #{str}")
      exit 1
    end

    def format(str)
      formatter.call(str)
    end

    # An HTTP parse error has occurred.
    # +server+ is the Server object, +env+ the request, and +error+ a
    # parsing exception.
    #
    def parse_error(server, env, error)
      @stderr.puts "#{Time.now}: HTTP parse error, malformed request (#{env[HTTP_X_FORWARDED_FOR] || env[REMOTE_ADDR]}): #{error.inspect}\n---\n"
    end

    # An SSL error has occurred.
    # +server+ is the Server object, +peeraddr+ peer address, +peercert+
    # any peer certificate (if present), and +error+ an exception object.
    #
    def ssl_error(server, peeraddr, peercert, error)
      subject = peercert ? peercert.subject : nil
      @stderr.puts "#{Time.now}: SSL error, peer: #{peeraddr}, peer cert: #{subject}, #{error.inspect}"
    end

    # An unknown error has occurred.
    # +server+ is the Server object, +error+ an exception object,
    # +kind+ some additional info, and +env+ the request.
    #
    def unknown_error(server, error, kind="Unknown", env=nil)
      if error.respond_to? :render
        error.render "#{Time.now}: #{kind} error", @stderr
      else
        if env
          string_block = [ "#{Time.now}: #{kind} error handling request { #{env['REQUEST_METHOD']} #{env['PATH_INFO']} }" ]
          string_block << error.inspect
        else
          string_block = [ "#{Time.now}: #{kind} error: #{error.inspect}" ]
        end
        string_block << error.backtrace
        @stderr.puts string_block.join("\n")
      end
    end

    def on_booted(&block)
      register(:on_booted, &block)
    end

    def fire_on_booted!
      fire(:on_booted)
    end

    DEFAULT = new(STDOUT, STDERR)

    # Returns an Events object which writes its status to 2 StringIO
    # objects.
    #
    def self.strings
      Events.new StringIO.new, StringIO.new
    end

    def self.stdio
      Events.new $stdout, $stderr
    end

    def self.null
      n = NullIO.new
      Events.new n, n
    end
  end
end
