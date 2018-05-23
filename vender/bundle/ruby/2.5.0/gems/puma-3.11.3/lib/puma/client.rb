class IO
  # We need to use this for a jruby work around on both 1.8 and 1.9.
  # So this either creates the constant (on 1.8), or harmlessly
  # reopens it (on 1.9).
  module WaitReadable
  end
end

require 'puma/detect'
require 'puma/delegation'
require 'tempfile'

if Puma::IS_JRUBY
  # We have to work around some OpenSSL buffer/io-readiness bugs
  # so we pull it in regardless of if the user is binding
  # to an SSL socket
  require 'openssl'
end

module Puma

  class ConnectionError < RuntimeError; end

  class Client
    include Puma::Const
    extend  Puma::Delegation

    def initialize(io, env=nil)
      @io = io
      @to_io = io.to_io
      @proto_env = env
      if !env
        @env = nil
      else
        @env = env.dup
      end

      @parser = HttpParser.new
      @parsed_bytes = 0
      @read_header = true
      @ready = false

      @body = nil
      @buffer = nil
      @tempfile = nil

      @timeout_at = nil

      @requests_served = 0
      @hijacked = false

      @peerip = nil
      @remote_addr_header = nil
    end

    attr_reader :env, :to_io, :body, :io, :timeout_at, :ready, :hijacked,
                :tempfile

    attr_writer :peerip

    attr_accessor :remote_addr_header

    forward :closed?, :@io

    def inspect
      "#<Puma::Client:0x#{object_id.to_s(16)} @ready=#{@ready.inspect}>"
    end

    # For the hijack protocol (allows us to just put the Client object
    # into the env)
    def call
      @hijacked = true
      env[HIJACK_IO] ||= @io
    end

    def in_data_phase
      !@read_header
    end

    def set_timeout(val)
      @timeout_at = Time.now + val
    end

    def reset(fast_check=true)
      @parser.reset
      @read_header = true
      @env = @proto_env.dup
      @body = nil
      @tempfile = nil
      @parsed_bytes = 0
      @ready = false

      if @buffer
        @parsed_bytes = @parser.execute(@env, @buffer, @parsed_bytes)

        if @parser.finished?
          return setup_body
        elsif @parsed_bytes >= MAX_HEADER
          raise HttpParserError,
            "HEADER is longer than allowed, aborting client early."
        end

        return false
      elsif fast_check &&
            IO.select([@to_io], nil, nil, FAST_TRACK_KA_TIMEOUT)
        return try_to_finish
      end
    end

    def close
      begin
        @io.close
      rescue IOError
        Thread.current.purge_interrupt_queue if Thread.current.respond_to? :purge_interrupt_queue
      end
    end

    # The object used for a request with no body. All requests with
    # no body share this one object since it has no state.
    EmptyBody = NullIO.new

    def setup_chunked_body(body)
      @chunked_body = true
      @partial_part_left = 0
      @prev_chunk = ""

      @body = Tempfile.new(Const::PUMA_TMP_BASE)
      @body.binmode
      @tempfile = @body

      return decode_chunk(body)
    end

    def decode_chunk(chunk)
      if @partial_part_left > 0
        if @partial_part_left <= chunk.size
          @body << chunk[0..(@partial_part_left-3)] # skip the \r\n
          chunk = chunk[@partial_part_left..-1]
        else
          @body << chunk
          @partial_part_left -= chunk.size
          return false
        end
      end

      if @prev_chunk.empty?
        io = StringIO.new(chunk)
      else
        io = StringIO.new(@prev_chunk+chunk)
        @prev_chunk = ""
      end

      while !io.eof?
        line = io.gets
        if line.end_with?("\r\n")
          len = line.strip.to_i(16)
          if len == 0
            @body.rewind
            rest = io.read
            @buffer = rest.empty? ? nil : rest
            @requests_served += 1
            @ready = true
            return true
          end

          len += 2

          part = io.read(len)

          unless part
            @partial_part_left = len
            next
          end

          got = part.size

          case
          when got == len
            @body << part[0..-3] # to skip the ending \r\n
          when got <= len - 2
            @body << part
            @partial_part_left = len - part.size
          when got == len - 1 # edge where we get just \r but not \n
            @body << part[0..-2]
            @partial_part_left = len - part.size
          end
        else
          @prev_chunk = line
          return false
        end
      end

      return false
    end

    def read_chunked_body
      while true
        begin
          chunk = @io.read_nonblock(4096)
        rescue Errno::EAGAIN
          return false
        rescue SystemCallError, IOError
          raise ConnectionError, "Connection error detected during read"
        end

        # No chunk means a closed socket
        unless chunk
          @body.close
          @buffer = nil
          @requests_served += 1
          @ready = true
          raise EOFError
        end

        return true if decode_chunk(chunk)
      end
    end

    def setup_body
      if @env[HTTP_EXPECT] == CONTINUE
        # TODO allow a hook here to check the headers before
        # going forward
        @io << HTTP_11_100
        @io.flush
      end

      @read_header = false

      body = @parser.body

      te = @env[TRANSFER_ENCODING2]

      if te && CHUNKED.casecmp(te) == 0
        return setup_chunked_body(body)
      end

      @chunked_body = false

      cl = @env[CONTENT_LENGTH]

      unless cl
        @buffer = body.empty? ? nil : body
        @body = EmptyBody
        @requests_served += 1
        @ready = true
        return true
      end

      remain = cl.to_i - body.bytesize

      if remain <= 0
        @body = StringIO.new(body)
        @buffer = nil
        @requests_served += 1
        @ready = true
        return true
      end

      if remain > MAX_BODY
        @body = Tempfile.new(Const::PUMA_TMP_BASE)
        @body.binmode
        @tempfile = @body
      else
        # The body[0,0] trick is to get an empty string in the same
        # encoding as body.
        @body = StringIO.new body[0,0]
      end

      @body.write body

      @body_remain = remain

      return false
    end

    def try_to_finish
      return read_body unless @read_header

      begin
        data = @io.read_nonblock(CHUNK_SIZE)
      rescue Errno::EAGAIN
        return false
      rescue SystemCallError, IOError
        raise ConnectionError, "Connection error detected during read"
      end

      # No data means a closed socket
      unless data
        @buffer = nil
        @requests_served += 1
        @ready = true
        raise EOFError
      end

      if @buffer
        @buffer << data
      else
        @buffer = data
      end

      @parsed_bytes = @parser.execute(@env, @buffer, @parsed_bytes)

      if @parser.finished?
        return setup_body
      elsif @parsed_bytes >= MAX_HEADER
        raise HttpParserError,
          "HEADER is longer than allowed, aborting client early."
      end

      false
    end

    if IS_JRUBY
      def jruby_start_try_to_finish
        return read_body unless @read_header

        begin
          data = @io.sysread_nonblock(CHUNK_SIZE)
        rescue OpenSSL::SSL::SSLError => e
          return false if e.kind_of? IO::WaitReadable
          raise e
        end

        # No data means a closed socket
        unless data
          @buffer = nil
          @requests_served += 1
          @ready = true
          raise EOFError
        end

        if @buffer
          @buffer << data
        else
          @buffer = data
        end

        @parsed_bytes = @parser.execute(@env, @buffer, @parsed_bytes)

        if @parser.finished?
          return setup_body
        elsif @parsed_bytes >= MAX_HEADER
          raise HttpParserError,
            "HEADER is longer than allowed, aborting client early."
        end

        false
      end

      def eagerly_finish
        return true if @ready

        if @io.kind_of? OpenSSL::SSL::SSLSocket
          return true if jruby_start_try_to_finish
        end

        return false unless IO.select([@to_io], nil, nil, 0)
        try_to_finish
      end

    else

      def eagerly_finish
        return true if @ready
        return false unless IO.select([@to_io], nil, nil, 0)
        try_to_finish
      end
    end # IS_JRUBY

    def finish
      return true if @ready
      until try_to_finish
        IO.select([@to_io], nil, nil)
      end
      true
    end

    def read_body
      if @chunked_body
        return read_chunked_body
      end

      # Read an odd sized chunk so we can read even sized ones
      # after this
      remain = @body_remain

      if remain > CHUNK_SIZE
        want = CHUNK_SIZE
      else
        want = remain
      end

      begin
        chunk = @io.read_nonblock(want)
      rescue Errno::EAGAIN
        return false
      rescue SystemCallError, IOError
        raise ConnectionError, "Connection error detected during read"
      end

      # No chunk means a closed socket
      unless chunk
        @body.close
        @buffer = nil
        @requests_served += 1
        @ready = true
        raise EOFError
      end

      remain -= @body.write(chunk)

      if remain <= 0
        @body.rewind
        @buffer = nil
        @requests_served += 1
        @ready = true
        return true
      end

      @body_remain = remain

      false
    end

    def write_400
      begin
        @io << ERROR_400_RESPONSE
      rescue StandardError
      end
    end

    def write_408
      begin
        @io << ERROR_408_RESPONSE
      rescue StandardError
      end
    end

    def write_500
      begin
        @io << ERROR_500_RESPONSE
      rescue StandardError
      end
    end

    def peerip
      return @peerip if @peerip

      if @remote_addr_header
        hdr = (@env[@remote_addr_header] || LOCALHOST_ADDR).split(/[\s,]/).first
        @peerip = hdr
        return hdr
      end

      @peerip ||= @io.peeraddr.last
    end
  end
end
