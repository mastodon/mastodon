# frozen_string_literal: true

require "forwardable"

require "http/headers"
require "http/response/parser"

module HTTP
  # A connection to the HTTP server
  class Connection
    extend Forwardable

    # Allowed values for CONNECTION header
    KEEP_ALIVE = "Keep-Alive"
    CLOSE      = "close"

    # Attempt to read this much data
    BUFFER_SIZE = 16_384

    # HTTP/1.0
    HTTP_1_0 = "1.0"

    # HTTP/1.1
    HTTP_1_1 = "1.1"

    # Returned after HTTP CONNECT (via proxy)
    attr_reader :proxy_response_headers

    # @param [HTTP::Request] req
    # @param [HTTP::Options] options
    # @raise [HTTP::ConnectionError] when failed to connect
    def initialize(req, options)
      @persistent           = options.persistent?
      @keep_alive_timeout   = options.keep_alive_timeout.to_f
      @pending_request      = false
      @pending_response     = false
      @failed_proxy_connect = false

      @parser = Response::Parser.new

      @socket = options.timeout_class.new(options.timeout_options)
      @socket.connect(options.socket_class, req.socket_host, req.socket_port, options.nodelay)

      send_proxy_connect_request(req)
      start_tls(req, options)
      reset_timer
    rescue IOError, SocketError, SystemCallError => ex
      raise ConnectionError, "failed to connect: #{ex}", ex.backtrace
    end

    # @see (HTTP::Response::Parser#status_code)
    def_delegator :@parser, :status_code

    # @see (HTTP::Response::Parser#http_version)
    def_delegator :@parser, :http_version

    # @see (HTTP::Response::Parser#headers)
    def_delegator :@parser, :headers

    # @return [Boolean] whenever proxy connect failed
    def failed_proxy_connect?
      @failed_proxy_connect
    end

    # Send a request to the server
    #
    # @param [Request] req Request to send to the server
    # @return [nil]
    def send_request(req)
      raise StateError, "Tried to send a request while one is pending already. Make sure you read off the body." if @pending_response
      raise StateError, "Tried to send a request while a response is pending. Make sure you read off the body."  if @pending_request

      @pending_request = true

      req.stream @socket

      @pending_response = true
      @pending_request  = false
    end

    # Read a chunk of the body
    #
    # @return [String] data chunk
    # @return [nil] when no more data left
    def readpartial(size = BUFFER_SIZE)
      return unless @pending_response

      finished = (read_more(size) == :eof) || @parser.finished?
      chunk    = @parser.chunk

      finish_response if finished

      chunk.to_s
    end

    # Reads data from socket up until headers are loaded
    # @return [void]
    def read_headers!
      loop do
        if read_more(BUFFER_SIZE) == :eof
          raise ConnectionError, "couldn't read response headers" unless @parser.headers?
          break
        elsif @parser.headers?
          break
        end
      end

      set_keep_alive
    end

    # Callback for when we've reached the end of a response
    # @return [void]
    def finish_response
      close unless keep_alive?

      @parser.reset
      @socket.reset_counter if @socket.respond_to?(:reset_counter)
      reset_timer

      @pending_response = false
    end

    # Close the connection
    # @return [void]
    def close
      @socket.close unless @socket.closed?

      @pending_response = false
      @pending_request  = false
    end

    # Whether we're keeping the conn alive
    # @return [Boolean]
    def keep_alive?
      !!@keep_alive && !@socket.closed?
    end

    # Whether our connection has expired
    # @return [Boolean]
    def expired?
      !@conn_expires_at || @conn_expires_at < Time.now
    end

    private

    # Sets up SSL context and starts TLS if needed.
    # @param (see #initialize)
    # @return [void]
    def start_tls(req, options)
      return unless req.uri.https? && !failed_proxy_connect?

      ssl_context = options.ssl_context

      unless ssl_context
        ssl_context = OpenSSL::SSL::SSLContext.new
        ssl_context.set_params(options.ssl || {})
      end

      @socket.start_tls(req.uri.host, options.ssl_socket_class, ssl_context)
    end

    # Open tunnel through proxy
    def send_proxy_connect_request(req)
      return unless req.uri.https? && req.using_proxy?

      @pending_request = true

      req.connect_using_proxy @socket

      @pending_request  = false
      @pending_response = true

      read_headers!
      @proxy_response_headers = @parser.headers

      if @parser.status_code != 200
        @failed_proxy_connect = true
        return
      end

      @parser.reset
      @pending_response = false
    end

    # Resets expiration of persistent connection.
    # @return [void]
    def reset_timer
      @conn_expires_at = Time.now + @keep_alive_timeout if @persistent
    end

    # Store whether the connection should be kept alive.
    # Once we reset the parser, we lose all of this state.
    # @return [void]
    def set_keep_alive
      return @keep_alive = false unless @persistent

      @keep_alive =
        case @parser.http_version
        when HTTP_1_0 # HTTP/1.0 requires opt in for Keep Alive
          @parser.headers[Headers::CONNECTION] == KEEP_ALIVE
        when HTTP_1_1 # HTTP/1.1 is opt-out
          @parser.headers[Headers::CONNECTION] != CLOSE
        else # Anything else we assume doesn't supportit
          false
        end
    end

    # Feeds some more data into parser
    # @return [void]
    def read_more(size)
      return if @parser.finished?

      value = @socket.readpartial(size)
      if value == :eof
        @parser << ""
        :eof
      elsif value
        @parser << value
      end
    rescue IOError, SocketError, SystemCallError => ex
      raise ConnectionError, "error reading from socket: #{ex}", ex.backtrace
    end
  end
end
