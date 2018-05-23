require "socket"
require "hiredis/ruby/reader"
require "hiredis/version"

module Hiredis
  module Ruby
    class Connection

      if defined?(RUBY_ENGINE) && RUBY_ENGINE == "rbx"

        def self.errno_to_class
          Errno::Mapping
        end

      else

        def self.errno_to_class
          @mapping ||= Hash[Errno.constants.map do |name|
            klass = Errno.const_get(name)
            [klass.const_get("Errno"), klass]
          end]
        end

      end

      if defined?(RUBY_ENGINE) && RUBY_ENGINE == "jruby"

        require "timeout"

        def _connect(host, port, timeout)
          sock = nil

          begin
            Timeout.timeout(timeout) do
              sock = TCPSocket.new(host, port)
            end
          rescue SocketError => se
            raise se.message
          rescue Timeout::Error
            raise Errno::ETIMEDOUT
          end

          sock
        end

        def _connect_unix(path, timeout)
          sock = nil

          begin
            Timeout.timeout(timeout) do
              sock = UNIXSocket.new(path)
            end
          rescue SocketError => se
            raise se.message
          rescue Timeout::Error
            raise Errno::ETIMEDOUT
          end

          sock
        end

        def _write(sock, data, timeout)
          begin
            Timeout.timeout(timeout) do
              sock.write(data)
            end
          rescue Timeout::Error
            raise Errno::EAGAIN
          end
        end

      else

        def _connect(host, port, timeout)
          error = nil
          sock = nil

          # Resolve address
          begin
            addrinfo = Socket.getaddrinfo(host, port, Socket::AF_UNSPEC, Socket::SOCK_STREAM)
          rescue SocketError => se
            raise se.message
          end

          addrinfo.each do |_, port, name, addr, af|
            begin
              sockaddr = Socket.pack_sockaddr_in(port, addr)
              sock = _connect_sockaddr(af, sockaddr, timeout)
            rescue => aux
              case aux
              when Errno::EAFNOSUPPORT, Errno::ECONNREFUSED
                error = aux
                next
              else
                # Re-raise
                raise
              end
            else
              # No errors, awesome!
              break
            end
          end

          unless sock
            # Re-raise last error since the last try obviously failed
            raise error if error

            # This code path should not happen: getaddrinfo should always return
            # at least one record, which should either succeed or fail and leave
            # and error to raise.
            raise
          end

          sock
        end

        def _connect_unix(path, timeout)
          sockaddr = Socket.pack_sockaddr_un(path)
          _connect_sockaddr(Socket::AF_UNIX, sockaddr, timeout)
        end

        def _write(sock, data, timeout)
          data.force_encoding("binary") if data.respond_to?(:force_encoding)

          begin
            nwritten = @sock.write_nonblock(data)

            while nwritten < string_size(data)
              data = data[nwritten..-1]
              nwritten = @sock.write_nonblock(data)
            end
          rescue Errno::EAGAIN
            if IO.select([], [@sock], [], timeout)
              # Writable, try again
              retry
            else
              # Timed out, raise
              raise Errno::EAGAIN
            end
          end
        end

        def _connect_sockaddr(af, sockaddr, timeout)
          sock = Socket.new(af, Socket::SOCK_STREAM, 0)

          begin
            sock.connect_nonblock(sockaddr)
          rescue Errno::EINPROGRESS
            if IO.select(nil, [sock], nil, timeout)
              # Writable, check for errors
              optval = sock.getsockopt(Socket::SOL_SOCKET, Socket::SO_ERROR)
              errno = optval.unpack("i").first

              # Raise socket error if there is any
              raise self.class.errno_to_class[errno] if errno > 0
            else
              # Timeout (TODO: replace with own Timeout class)
              raise Errno::ETIMEDOUT
            end
          end

          sock
        rescue
          sock.close if sock

          # Re-raise
          raise
        end

        private :_connect_sockaddr

      end

      attr_reader :sock

      def initialize
        @sock = nil
        @timeout = nil
      end

      def connected?
        !! @sock
      end

      def connect(host, port, usecs = nil)
        # Temporarily override timeout on #connect
        timeout = usecs ? (usecs / 1_000_000.0) : @timeout

        # Optionally disconnect current socket
        disconnect if connected?

        sock = _connect(host, port, timeout)
        sock.setsockopt Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1

        @reader = ::Hiredis::Ruby::Reader.new
        @sock = sock

        nil
      end

      def connect_unix(path, usecs = 0)
        # Temporarily override timeout on #connect
        timeout = usecs ? (usecs / 1_000_000.0) : @timeout

        # Optionally disconnect current socket
        disconnect if connected?

        sock = _connect_unix(path, timeout)

        @reader = ::Hiredis::Ruby::Reader.new
        @sock = sock

        nil
      end

      def disconnect
        @sock.close
      rescue
      ensure
        @sock = nil
      end

      def timeout=(usecs)
        raise ArgumentError.new("timeout cannot be negative") if usecs < 0

        if usecs == 0
          @timeout = nil
        else
          @timeout = usecs / 1_000_000.0
        end

        nil
      end

      def fileno
        raise "not connected" unless connected?

        @sock.fileno
      end

      COMMAND_DELIMITER = "\r\n".freeze

      def write(args)
        command = []
        command << "*#{args.size}"
        args.each do |arg|
          arg = arg.to_s
          command << "$#{string_size arg}"
          command << arg
        end

        data = command.join(COMMAND_DELIMITER) + COMMAND_DELIMITER

        _write(@sock, data, @timeout)

        nil
      end

      # No-op for now..
      def flush
      end

      def read
        raise "not connected" unless connected?

        while (reply = @reader.gets) == false
          begin
            @reader.feed @sock.read_nonblock(1024)
          rescue Errno::EAGAIN
            if IO.select([@sock], [], [], @timeout)
              # Readable, try again
              retry
            else
              # Timed out, raise
              raise Errno::EAGAIN
            end
          end
        end

        reply
      rescue ::EOFError
        raise Errno::ECONNRESET
      end

    protected

      if "".respond_to?(:bytesize)
        def string_size(string)
          string.to_s.bytesize
        end
      else
        def string_size(string)
          string.to_s.size
        end
      end
    end
  end
end
