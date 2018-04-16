# frozen_string_literal: true

require "timeout"
require "io/wait"

require "http/timeout/per_operation"

module HTTP
  module Timeout
    class Global < PerOperation
      attr_reader :time_left, :total_timeout

      def initialize(*args)
        super
        reset_counter
      end

      # To future me: Don't remove this again, past you was smarter.
      def reset_counter
        @time_left = connect_timeout + read_timeout + write_timeout
        @total_timeout = time_left
      end

      def connect(socket_class, host, port, nodelay = false)
        reset_timer
        ::Timeout.timeout(time_left, TimeoutError) do
          @socket = socket_class.open(host, port)
          @socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1) if nodelay
        end

        log_time
      end

      def connect_ssl
        reset_timer

        begin
          @socket.connect_nonblock
        rescue IO::WaitReadable
          IO.select([@socket], nil, nil, time_left)
          log_time
          retry
        rescue IO::WaitWritable
          IO.select(nil, [@socket], nil, time_left)
          log_time
          retry
        end
      end

      # Read from the socket
      def readpartial(size)
        perform_io { read_nonblock(size) }
      end

      # Write to the socket
      def write(data)
        perform_io { write_nonblock(data) }
      end

      alias << write

      private

      if RUBY_VERSION < "2.1.0"
        def read_nonblock(size)
          @socket.read_nonblock(size)
        end

        def write_nonblock(data)
          @socket.write_nonblock(data)
        end
      else
        def read_nonblock(size)
          @socket.read_nonblock(size, :exception => false)
        end

        def write_nonblock(data)
          @socket.write_nonblock(data, :exception => false)
        end
      end

      # Perform the given I/O operation with the given argument
      def perform_io
        reset_timer

        loop do
          begin
            result = yield

            case result
            when :wait_readable then wait_readable_or_timeout
            when :wait_writable then wait_writable_or_timeout
            when NilClass       then return :eof
            else                return result
            end
          rescue IO::WaitReadable
            wait_readable_or_timeout
          rescue IO::WaitWritable
            wait_writable_or_timeout
          end
        end
      rescue EOFError
        :eof
      end

      # Wait for a socket to become readable
      def wait_readable_or_timeout
        @socket.to_io.wait_readable(time_left)
        log_time
      end

      # Wait for a socket to become writable
      def wait_writable_or_timeout
        @socket.to_io.wait_writable(time_left)
        log_time
      end

      # Due to the run/retry nature of nonblocking I/O, it's easier to keep track of time
      # via method calls instead of a block to monitor.
      def reset_timer
        @started = Time.now
      end

      def log_time
        @time_left -= (Time.now - @started)
        if time_left <= 0
          raise TimeoutError, "Timed out after using the allocated #{total_timeout} seconds"
        end

        reset_timer
      end
    end
  end
end
