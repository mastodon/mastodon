require "socket"

module RedisMock
  class Server
    def initialize(options = {}, &block)
      tcp_server = TCPServer.new(options[:host] || "127.0.0.1", 0)
      tcp_server.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)

      if options[:ssl]
        ctx = OpenSSL::SSL::SSLContext.new

        ssl_params = options.fetch(:ssl_params, {})
        ctx.set_params(ssl_params) unless ssl_params.empty?

        @server = OpenSSL::SSL::SSLServer.new(tcp_server, ctx)
      else
        @server = tcp_server
      end
    end

    def port
      @server.addr[1]
    end

    def start(&block)
      @thread = Thread.new { run(&block) }
    end

    def shutdown
      @thread.kill
    end

    def run
      begin
        loop do
          session = @server.accept

          begin
            return if yield(session) == :exit
          ensure
            session.close
          end
        end
      rescue => ex
        $stderr.puts "Error running mock server: #{ex.message}"
        $stderr.puts ex.backtrace
        retry
      ensure
        @server.close
      end
    end
  end

  # Starts a mock Redis server in a thread.
  #
  # The server will use the lambda handler passed as argument to handle
  # connections. For example:
  #
  #   handler = lambda { |session| session.close }
  #   RedisMock.start_with_handler(handler) do
  #     # Every connection will be closed immediately
  #   end
  #
  def self.start_with_handler(blk, options = {})
    server = Server.new(options)
    port = server.port

    begin
      server.start(&blk)
      yield(port)
    ensure
      server.shutdown
    end
  end

  # Starts a mock Redis server in a thread.
  #
  # The server will reply with a `+OK` to all commands, but you can
  # customize it by providing a hash. For example:
  #
  #   RedisMock.start(:ping => lambda { "+PONG" }) do |port|
  #     assert_equal "PONG", Redis.new(:port => port).ping
  #   end
  #
  def self.start(commands, options = {}, &blk)
    handler = lambda do |session|
      while line = session.gets
        argv = Array.new(line[1..-3].to_i) do
          bytes = session.gets[1..-3].to_i
          arg = session.read(bytes)
          session.read(2) # Discard \r\n
          arg
        end

        command = argv.shift
        blk = commands[command.to_sym]
        blk ||= lambda { |*_| "+OK" }

        response = blk.call(*argv)

        # Convert a nil response to :close
        response ||= :close

        if response == :exit
          break :exit
        elsif response == :close
          break :close
        elsif response.is_a?(Array)
          session.write("*%d\r\n" % response.size)

          response.each do |resp|
            if resp.is_a?(Array)
              session.write("*%d\r\n" % resp.size)
              resp.each do |r|
                session.write("$%d\r\n%s\r\n" % [r.length, r])
              end
            else
              session.write("$%d\r\n%s\r\n" % [resp.length, resp])
            end
          end
        else
          session.write(response)
          session.write("\r\n") unless response.end_with?("\r\n")
        end
      end
    end

    start_with_handler(handler, options, &blk)
  end
end
