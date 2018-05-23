# frozen_string_literal: true
module Excon
  class Socket
    include Utils

    extend Forwardable

    attr_accessor :data

    def params
      Excon.display_warning('Excon::Socket#params is deprecated use Excon::Socket#data instead.')
      @data
    end

    def params=(new_params)
      Excon.display_warning('Excon::Socket#params= is deprecated use Excon::Socket#data= instead.')
      @data = new_params
    end

    attr_reader :remote_ip

    def_delegators(:@socket, :close)

    def initialize(data = {})
      @data = data
      @nonblock = data[:nonblock]
      @port ||= @data[:port] || 80
      @read_buffer = String.new
      @eof = false
      connect
    end

    def read(max_length = nil)
      if @eof
        return max_length ? nil : ''
      elsif @nonblock
        read_nonblock(max_length)
      else
        read_block(max_length)
      end
    end

    def readline
      return legacy_readline if RUBY_VERSION.to_f <= 1.8_7
      buffer = String.new
      begin
        buffer << @socket.read_nonblock(1) while buffer[-1] != "\n"
        buffer
      rescue Errno::EAGAIN, Errno::EWOULDBLOCK, IO::WaitReadable
        select_with_timeout(@socket, :read) && retry
      rescue OpenSSL::SSL::SSLError => error
        if error.message == 'read would block'
          select_with_timeout(@socket, :read) && retry
        else
          raise(error)
        end
      end
    end

    def legacy_readline
      begin
        Timeout.timeout(@data[:read_timeout]) do
          @socket.readline
        end
      rescue Timeout::Error
        raise Excon::Errors::Timeout.new('read timeout reached')
      end
    end

    def write(data)
      if @nonblock
        write_nonblock(data)
      else
        write_block(data)
      end
    end

    def local_address
      unpacked_sockaddr[1]
    end

    def local_port
      unpacked_sockaddr[0]
    end

    private

    def connect
      @socket = nil
      exception = nil

      if @data[:proxy]
        family = @data[:proxy][:family] || ::Socket::Constants::AF_UNSPEC
        args = [@data[:proxy][:hostname], @data[:proxy][:port], family, ::Socket::Constants::SOCK_STREAM]
      else
        family = @data[:family] || ::Socket::Constants::AF_UNSPEC
        args = [@data[:hostname], @port, family, ::Socket::Constants::SOCK_STREAM]
      end
      if RUBY_VERSION >= '1.9.2' && defined?(RUBY_ENGINE) && RUBY_ENGINE == 'ruby'
        args << nil << nil << false # no reverse lookup
      end
      addrinfo = ::Socket.getaddrinfo(*args)

      addrinfo.each do |_, port, _, ip, a_family, s_type|
        # already succeeded on previous addrinfo
        if @socket
          break
        end
        
        @remote_ip = ip

        # nonblocking connect
        begin
          sockaddr = ::Socket.sockaddr_in(port, ip)

          socket = ::Socket.new(a_family, s_type, 0)

          if @data[:reuseaddr]
            socket.setsockopt(::Socket::Constants::SOL_SOCKET, ::Socket::Constants::SO_REUSEADDR, true)
            if defined?(::Socket::Constants::SO_REUSEPORT)
              socket.setsockopt(::Socket::Constants::SOL_SOCKET, ::Socket::Constants::SO_REUSEPORT, true)
            end
          end

          if @nonblock
            socket.connect_nonblock(sockaddr)
          else
            socket.connect(sockaddr)
          end
          @socket = socket
        rescue Errno::EINPROGRESS
          select_with_timeout(socket, :connect_write)
          begin
            socket.connect_nonblock(sockaddr)
            @socket = socket
          rescue Errno::EISCONN
            @socket = socket
          rescue SystemCallError => exception
            socket.close rescue nil
          end
        rescue SystemCallError => exception
          socket.close rescue nil if socket
        end
      end

      # this will be our last encountered exception
      fail exception unless @socket

      if @data[:tcp_nodelay]
        @socket.setsockopt(::Socket::IPPROTO_TCP,
                           ::Socket::TCP_NODELAY,
                           true)
      end
    end

    def read_nonblock(max_length)
      begin
        if max_length
          until @read_buffer.length >= max_length
            @read_buffer << @socket.read_nonblock(max_length - @read_buffer.length)
          end
        else
          loop do
            @read_buffer << @socket.read_nonblock(@data[:chunk_size])
          end
        end
      rescue OpenSSL::SSL::SSLError => error
        if error.message == 'read would block'
          select_with_timeout(@socket, :read) && retry
        else
          raise(error)
        end
      rescue Errno::EAGAIN, Errno::EWOULDBLOCK, IO::WaitReadable
        if @read_buffer.empty?
          # if we didn't read anything, try again...
          select_with_timeout(@socket, :read) && retry
        end
      rescue EOFError
        @eof = true
      end

      if max_length
        if @read_buffer.empty?
          nil # EOF met at beginning
        else
          @read_buffer.slice!(0, max_length)
        end
      else
        # read until EOFError, so return everything
        @read_buffer.slice!(0, @read_buffer.length)
      end
    end

    def read_block(max_length)
      @socket.read(max_length)
    rescue OpenSSL::SSL::SSLError => error
      if error.message == 'read would block'
        select_with_timeout(@socket, :read) && retry
      else
        raise(error)
      end
    rescue Errno::EAGAIN, Errno::EWOULDBLOCK, IO::WaitReadable
      if @read_buffer.empty?
        select_with_timeout(@socket, :read) && retry
      end
    rescue EOFError
      @eof = true
    end

    def write_nonblock(data)
      if FORCE_ENC
        data.force_encoding('BINARY')
      end
      loop do
        written = nil
        begin
          # I wish that this API accepted a start position, then we wouldn't
          # have to slice data when there is a short write.
          written = @socket.write_nonblock(data)
        rescue Errno::EFAULT => error
          if OpenSSL.const_defined?(:OPENSSL_LIBRARY_VERSION) && OpenSSL::OPENSSL_LIBRARY_VERSION.split(' ')[1] == '1.0.2'
            msg = "The version of OpenSSL this ruby is built against (1.0.2) has a vulnerability
                   which causes a fault. For more, see https://github.com/excon/excon/issues/467"
            raise SecurityError.new(msg)
          else
            raise error
          end
        rescue OpenSSL::SSL::SSLError, Errno::EAGAIN, Errno::EWOULDBLOCK, IO::WaitWritable => error
          if error.is_a?(OpenSSL::SSL::SSLError) && error.message != 'write would block'
            raise error
          else
            select_with_timeout(@socket, :write) && retry
          end
        end

        # Fast, common case.
        break if written == data.size

        # This takes advantage of the fact that most ruby implementations
        # have Copy-On-Write strings. Thusly why requesting a subrange
        # of data, we actually don't copy data because the new string
        # simply references a subrange of the original.
        data = data[written, data.size]
      end
    end

    def write_block(data)
      @socket.write(data)
    rescue OpenSSL::SSL::SSLError, Errno::EAGAIN, Errno::EWOULDBLOCK, IO::WaitWritable => error
      if error.is_a?(OpenSSL::SSL::SSLError) && error.message != 'write would block'
        raise error
      else
        select_with_timeout(@socket, :write) && retry
      end
    end

    def select_with_timeout(socket, type)
      select = case type
      when :connect_read
        IO.select([socket], nil, nil, @data[:connect_timeout])
      when :connect_write
        IO.select(nil, [socket], nil, @data[:connect_timeout])
      when :read
        IO.select([socket], nil, nil, @data[:read_timeout])
      when :write
        IO.select(nil, [socket], nil, @data[:write_timeout])
      end
      select || raise(Excon::Errors::Timeout.new("#{type} timeout reached"))
    end

    def unpacked_sockaddr
      @unpacked_sockaddr ||= ::Socket.unpack_sockaddr_in(@socket.to_io.getsockname)
    rescue ArgumentError => e
      unless e.message == 'not an AF_INET/AF_INET6 sockaddr'
        raise
      end
    end
  end
end
