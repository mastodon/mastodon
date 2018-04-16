# frozen_string_literal: true

require "forwardable"

require "http/headers"
require "http/content_type"
require "http/mime_type"
require "http/response/status"
require "http/response/inflater"
require "http/uri"
require "http/cookie_jar"
require "time"

module HTTP
  class Response
    extend Forwardable

    include HTTP::Headers::Mixin

    # @return [Status]
    attr_reader :status

    # @return [Body]
    attr_reader :body

    # @return [URI, nil]
    attr_reader :uri

    # @return [Hash]
    attr_reader :proxy_headers

    # Inits a new instance
    #
    # @option opts [Integer] :status Status code
    # @option opts [String] :version HTTP version
    # @option opts [Hash] :headers
    # @option opts [Hash] :proxy_headers
    # @option opts [HTTP::Connection] :connection
    # @option opts [String] :encoding Encoding to use when reading body
    # @option opts [String] :body
    # @option opts [String] :uri
    def initialize(opts)
      @version       = opts.fetch(:version)
      @uri           = HTTP::URI.parse(opts.fetch(:uri)) if opts.include? :uri
      @status        = HTTP::Response::Status.new(opts.fetch(:status))
      @headers       = HTTP::Headers.coerce(opts[:headers] || {})
      @proxy_headers = HTTP::Headers.coerce(opts[:proxy_headers] || {})

      if opts.include?(:connection)
        connection = opts.fetch(:connection)
        encoding   = opts[:encoding] || charset || Encoding::BINARY
        stream     = body_stream_for(connection, opts)

        @body = Response::Body.new(stream, :encoding => encoding)
      else
        @body = opts.fetch(:body)
      end
    end

    # @!method reason
    #   @return (see HTTP::Response::Status#reason)
    def_delegator :status, :reason

    # @!method code
    #   @return (see HTTP::Response::Status#code)
    def_delegator :status, :code

    # @!method to_s
    #   (see HTTP::Response::Body#to_s)
    def_delegator :body, :to_s
    alias to_str to_s

    # @!method readpartial
    #   (see HTTP::Response::Body#readpartial)
    def_delegator :body, :readpartial

    # @!method connection
    #   (see HTTP::Response::Body#connection)
    def_delegator :body, :connection

    # Returns an Array ala Rack: `[status, headers, body]`
    #
    # @return [Array(Fixnum, Hash, String)]
    def to_a
      [status.to_i, headers.to_h, body.to_s]
    end

    # Flushes body and returns self-reference
    #
    # @return [Response]
    def flush
      body.to_s
      self
    end

    # Value of the Content-Length header.
    #
    # @return [nil] if Content-Length was not given, or it's value was invalid
    #   (not an integer, e.g. empty string or string with non-digits).
    # @return [Integer] otherwise
    def content_length
      # http://greenbytes.de/tech/webdav/rfc7230.html#rfc.section.3.3.3
      # Clause 3: "If a message is received with both a Transfer-Encoding
      # and a Content-Length header field, the Transfer-Encoding overrides the Content-Length.
      return nil if @headers.include?(Headers::TRANSFER_ENCODING)

      value = @headers[Headers::CONTENT_LENGTH]
      return nil unless value

      begin
        Integer(value)
      rescue ArgumentError
        nil
      end
    end

    # Parsed Content-Type header
    #
    # @return [HTTP::ContentType]
    def content_type
      @content_type ||= ContentType.parse headers[Headers::CONTENT_TYPE]
    end

    # @!method mime_type
    #   MIME type of response (if any)
    #   @return [String, nil]
    def_delegator :content_type, :mime_type

    # @!method charset
    #   Charset of response (if any)
    #   @return [String, nil]
    def_delegator :content_type, :charset

    def cookies
      @cookies ||= headers.each_with_object CookieJar.new do |(k, v), jar|
        jar.parse(v, uri) if k == Headers::SET_COOKIE
      end
    end

    def chunked?
      return false unless @headers.include?(Headers::TRANSFER_ENCODING)

      encoding = @headers.get(Headers::TRANSFER_ENCODING)

      # TODO: "chunked" is frozen in the request writer. How about making it accessible?
      encoding.last == "chunked"
    end

    # Parse response body with corresponding MIME type adapter.
    #
    # @param [#to_s] as Parse as given MIME type
    #   instead of the one determined from headers
    # @raise [HTTP::Error] if adapter not found
    # @return [Object]
    def parse(as = nil)
      MimeType[as || mime_type].decode to_s
    end

    # Inspect a response
    def inspect
      "#<#{self.class}/#{@version} #{code} #{reason} #{headers.to_h.inspect}>"
    end

    private

    def body_stream_for(connection, opts)
      if opts[:auto_inflate]
        opts[:auto_inflate].stream_for(connection, self)
      else
        connection
      end
    end
  end
end
