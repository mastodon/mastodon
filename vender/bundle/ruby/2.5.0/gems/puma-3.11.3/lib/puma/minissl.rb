begin
  require 'io/wait'
  rescue LoadError
end

module Puma
  module MiniSSL
    class Socket
      def initialize(socket, engine)
        @socket = socket
        @engine = engine
        @peercert = nil
      end

      def to_io
        @socket
      end

      def closed?
        @socket.closed?
      end

      def readpartial(size)
        while true
          output = @engine.read
          return output if output

          data = @socket.readpartial(size)
          @engine.inject(data)
          output = @engine.read

          return output if output

          while neg_data = @engine.extract
            @socket.write neg_data
          end
        end
      end

      def engine_read_all
        output = @engine.read
        while output and additional_output = @engine.read
          output << additional_output
        end
        output
      end

      def read_nonblock(size, *_)
        # *_ is to deal with keyword args that were added
        # at some point (and being used in the wild)
        while true
          output = engine_read_all
          return output if output

          begin
            data = @socket.read_nonblock(size, exception: false)
            if data == :wait_readable || data == :wait_writable
              if @socket.to_io.respond_to?(data)
                @socket.to_io.__send__(data)
              elsif data == :wait_readable
                IO.select([@socket.to_io])
              else
                IO.select(nil, [@socket.to_io])
              end
            elsif !data
              return nil
            else
              break
            end
          end while true

          @engine.inject(data)
          output = engine_read_all

          return output if output

          while neg_data = @engine.extract
            @socket.write neg_data
          end
        end
      end

      def write(data)
        return 0 if data.empty?

        need = data.bytesize

        while true
          wrote = @engine.write data
          enc = @engine.extract

          while enc
            @socket.write enc
            enc = @engine.extract
          end

          need -= wrote

          return data.bytesize if need == 0

          data = data[wrote..-1]
        end
      end

      alias_method :syswrite, :write
      alias_method :<<, :write

      # This is a temporary fix to deal with websockets code using
      # write_nonblock. The problem with implementing it properly
      # is that it means we'd have to have the ability to rewind
      # an engine because after we write+extract, the socket
      # write_nonblock call might raise an exception and later
      # code would pass the same data in, but the engine would think
      # it had already written the data in. So for the time being
      # (and since write blocking is quite rare), go ahead and actually
      # block in write_nonblock.
      def write_nonblock(data, *_)
        write data
      end

      def flush
        @socket.flush
      end

      def read_and_drop(timeout = 1)
        return :timeout unless IO.select([@socket], nil, nil, timeout)
        read_nonblock(1024)
        :drop
      rescue Errno::EAGAIN
        # do nothing
        :eagain
      end

      def should_drop_bytes?
        @engine.init? || !@engine.shutdown
      end

      def close
        begin
          # Read any drop any partially initialized sockets and any received bytes during shutdown.
          # Don't let this socket hold this loop forever.
          # If it can't send more packets within 1s, then give up.
          while should_drop_bytes?
            return if read_and_drop(1) == :timeout
          end
        rescue IOError, SystemCallError
          Thread.current.purge_interrupt_queue if Thread.current.respond_to? :purge_interrupt_queue
          # nothing
        ensure
          @socket.close
        end
      end

      def peeraddr
        @socket.peeraddr
      end

      def peercert
        return @peercert if @peercert

        raw = @engine.peercert
        return nil unless raw

        @peercert = OpenSSL::X509::Certificate.new raw
      end
    end

    if defined?(JRUBY_VERSION)
      class SSLError < StandardError
        # Define this for jruby even though it isn't used.
      end

      def self.check; end
    end

    class Context
      attr_accessor :verify_mode

      if defined?(JRUBY_VERSION)
        # jruby-specific Context properties: java uses a keystore and password pair rather than a cert/key pair
        attr_reader :keystore
        attr_accessor :keystore_pass

        def keystore=(keystore)
          raise ArgumentError, "No such keystore file '#{keystore}'" unless File.exist? keystore
          @keystore = keystore
        end

        def check
          raise "Keystore not configured" unless @keystore
        end

      else
        # non-jruby Context properties
        attr_reader :key
        attr_reader :cert
        attr_reader :ca

        def key=(key)
          raise ArgumentError, "No such key file '#{key}'" unless File.exist? key
          @key = key
        end

        def cert=(cert)
          raise ArgumentError, "No such cert file '#{cert}'" unless File.exist? cert
          @cert = cert
        end

        def ca=(ca)
          raise ArgumentError, "No such ca file '#{ca}'" unless File.exist? ca
          @ca = ca
        end

        def check
          raise "Key not configured" unless @key
          raise "Cert not configured" unless @cert
        end
      end
    end

    VERIFY_NONE = 0
    VERIFY_PEER = 1
    VERIFY_FAIL_IF_NO_PEER_CERT = 2

    class Server
      def initialize(socket, ctx)
        @socket = socket
        @ctx = ctx
      end

      def to_io
        @socket
      end

      def accept
        @ctx.check
        io = @socket.accept
        engine = Engine.server @ctx

        Socket.new io, engine
      end

      def accept_nonblock
        @ctx.check
        io = @socket.accept_nonblock
        engine = Engine.server @ctx

        Socket.new io, engine
      end

      def close
        @socket.close
      end
    end
  end
end
