# frozen_string_literal: true

require "forwardable"

require "http/form_data"
require "http/options"
require "http/headers"
require "http/connection"
require "http/redirector"
require "http/uri"

module HTTP
  # Clients make requests and receive responses
  class Client
    extend Forwardable
    include Chainable

    HTTP_OR_HTTPS_RE = %r{^https?://}i

    def initialize(default_options = {})
      @default_options = HTTP::Options.new(default_options)
      @connection = nil
      @state = :clean
    end

    # Make an HTTP request
    def request(verb, uri, opts = {}) # rubocop:disable Style/OptionHash
      opts    = @default_options.merge(opts)
      uri     = make_request_uri(uri, opts)
      headers = make_request_headers(opts)
      body    = make_request_body(opts, headers)
      proxy   = opts.proxy

      req = HTTP::Request.new(
        :verb         => verb,
        :uri          => uri,
        :headers      => headers,
        :proxy        => proxy,
        :body         => body,
        :auto_deflate => opts.feature(:auto_deflate)
      )

      res = perform(req, opts)
      return res unless opts.follow

      Redirector.new(opts.follow).perform(req, res) do |request|
        perform(request, opts)
      end
    end

    # @!method persistent?
    #   @see Options#persistent?
    #   @return [Boolean] whenever client is persistent
    def_delegator :default_options, :persistent?

    # Perform a single (no follow) HTTP request
    def perform(req, options)
      verify_connection!(req.uri)

      @state = :dirty

      @connection ||= HTTP::Connection.new(req, options)

      unless @connection.failed_proxy_connect?
        @connection.send_request(req)
        @connection.read_headers!
      end

      res = Response.new(
        :status        => @connection.status_code,
        :version       => @connection.http_version,
        :headers       => @connection.headers,
        :proxy_headers => @connection.proxy_response_headers,
        :connection    => @connection,
        :encoding      => options.encoding,
        :auto_inflate  => options.feature(:auto_inflate),
        :uri           => req.uri
      )

      @connection.finish_response if req.verb == :head
      @state = :clean

      res
    rescue
      close
      raise
    end

    def close
      @connection.close if @connection
      @connection = nil
      @state = :clean
    end

    private

    # Verify our request isn't going to be made against another URI
    def verify_connection!(uri)
      if default_options.persistent? && uri.origin != default_options.persistent
        raise StateError, "Persistence is enabled for #{default_options.persistent}, but we got #{uri.origin}"
      # We re-create the connection object because we want to let prior requests
      # lazily load the body as long as possible, and this mimics prior functionality.
      elsif @connection && (!@connection.keep_alive? || @connection.expired?)
        close
      # If we get into a bad state (eg, Timeout.timeout ensure being killed)
      # close the connection to prevent potential for mixed responses.
      elsif @state == :dirty
        close
      end
    end

    # Merges query params if needed
    #
    # @param [#to_s] uri
    # @return [URI]
    def make_request_uri(uri, opts)
      uri = uri.to_s

      if default_options.persistent? && uri !~ HTTP_OR_HTTPS_RE
        uri = "#{default_options.persistent}#{uri}"
      end

      uri = HTTP::URI.parse uri

      if opts.params && !opts.params.empty?
        uri.query = [uri.query, HTTP::URI.form_encode(opts.params)].compact.join("&")
      end

      # Some proxies (seen on WEBRick) fail if URL has
      # empty path (e.g. `http://example.com`) while it's RFC-complaint:
      # http://tools.ietf.org/html/rfc1738#section-3.1
      uri.path = "/" if uri.path.empty?

      uri
    end

    # Creates request headers with cookies (if any) merged in
    def make_request_headers(opts)
      headers = opts.headers

      # Tell the server to keep the conn open
      headers[Headers::CONNECTION] = default_options.persistent? ? Connection::KEEP_ALIVE : Connection::CLOSE

      cookies = opts.cookies.values

      unless cookies.empty?
        cookies = opts.headers.get(Headers::COOKIE).concat(cookies).join("; ")
        headers[Headers::COOKIE] = cookies
      end

      if (auto_deflate = opts.feature(:auto_deflate))
        # We need to delete Content-Length header. It will be set automatically
        # by HTTP::Request::Writer
        headers.delete(Headers::CONTENT_LENGTH)

        headers[Headers::CONTENT_ENCODING] = auto_deflate.method
      end

      headers
    end

    # Create the request body object to send
    def make_request_body(opts, headers)
      case
      when opts.body
        opts.body
      when opts.form
        form = HTTP::FormData.create opts.form
        headers[Headers::CONTENT_TYPE] ||= form.content_type
        form
      when opts.json
        body = MimeType[:json].encode opts.json
        headers[Headers::CONTENT_TYPE] ||= "application/json; charset=#{body.encoding.name}"
        body
      end
    end
  end
end
