require 'net/https'
require 'openssl'

module Seahorse
  module Client
    # @api private
    module NetHttp

      # The default HTTP handler for Seahorse::Client.  This is based on
      # the Ruby's `Net::HTTP`.
      class Handler < Client::Handler

        # @api private
        class TruncatedBodyError < IOError
          def initialize(bytes_expected, bytes_received)
            msg = "http response body truncated, expected #{bytes_expected} "
            msg << "bytes, received #{bytes_received} bytes"
            super(msg)
          end
        end

        NETWORK_ERRORS = [
          SocketError, EOFError, IOError, Timeout::Error,
          Errno::ECONNABORTED, Errno::ECONNRESET, Errno::EPIPE,
          Errno::EINVAL, Errno::ETIMEDOUT, OpenSSL::SSL::SSLError,
          Errno::EHOSTUNREACH, Errno::ECONNREFUSED
        ]

        # does not exist in Ruby 1.9.3
        if OpenSSL::SSL.const_defined?(:SSLErrorWaitReadable)
          NETWORK_ERRORS << OpenSSL::SSL::SSLErrorWaitReadable
        end

        # @api private
        DNS_ERROR_MESSAGES = [
          'getaddrinfo: nodename nor servname provided, or not known', # MacOS
          'getaddrinfo: Name or service not known' # GNU
        ]

        # Raised when a {Handler} cannot construct a `Net::HTTP::Request`
        # from the given http verb.
        class InvalidHttpVerbError < StandardError; end

        # @param [RequestContext] context
        # @return [Response]
        def call(context)
          transmit(context.config, context.http_request, context.http_response)
          Response.new(context: context)
        end

        # @param [Configuration] config
        # @return [ConnectionPool]
        def pool_for(config)
          ConnectionPool.for(pool_options(config))
        end

        private

        def error_message(req, error)
          if error.is_a?(SocketError) && DNS_ERROR_MESSAGES.include?(error.message)
            host = req.endpoint.host
            "unable to connect to `#{host}`; SocketError: #{error.message}"
          else
            error.message
          end
        end

        # @param [Configuration] config
        # @param [Http::Request] req
        # @param [Http::Response] resp
        # @return [void]
        def transmit(config, req, resp)
          session(config, req) do |http|
            http.request(build_net_request(req)) do |net_resp|

              status_code = net_resp.code.to_i
              headers = extract_headers(net_resp)

              bytes_received = 0
              resp.signal_headers(status_code, headers)
              net_resp.read_body do |chunk|
                bytes_received += chunk.bytesize
                resp.signal_data(chunk)
              end
              complete_response(req, resp, bytes_received)

            end
          end
        rescue *NETWORK_ERRORS => error
          # these are retryable
          error = NetworkingError.new(error, error_message(req, error))
          resp.signal_error(error)
        rescue => error
          # not retryable
          resp.signal_error(error)
        end

        def complete_response(req, resp, bytes_received)
          if should_verify_bytes?(req, resp)
            verify_bytes_received(resp, bytes_received)
          else
            resp.signal_done
          end
        end

        def should_verify_bytes?(req, resp)
          req.http_method != 'HEAD' && resp.headers['content-length']
        end

        def verify_bytes_received(resp, bytes_received)
          bytes_expected = resp.headers['content-length'].to_i
          if bytes_expected == bytes_received
            resp.signal_done
          else
            error = TruncatedBodyError.new(bytes_expected, bytes_received)
            resp.signal_error(NetworkingError.new(error, error.message))
          end
        end

        def session(config, req, &block)
          pool_for(config).session_for(req.endpoint) do |http|
            http.read_timeout = config.http_read_timeout
            yield(http)
          end
        end

        # Extracts the {ConnectionPool} configuration options.
        # @param [Configuration] config
        # @return [Hash]
        def pool_options(config)
          ConnectionPool::OPTIONS.keys.inject({}) do |opts,opt|
            opts[opt] = config.send(opt)
            opts
          end
        end

        # Constructs and returns a Net::HTTP::Request object from
        # a {Http::Request}.
        # @param [Http::Request] request
        # @return [Net::HTTP::Request]
        def build_net_request(request)
          request_class = net_http_request_class(request)
          req = request_class.new(request.endpoint.request_uri, headers(request))
          req.body_stream = request.body
          req
        end

        # @param [Http::Request] request
        # @raise [InvalidHttpVerbError]
        # @return Returns a base `Net::HTTP::Request` class, e.g.,
        #   `Net::HTTP::Get`, `Net::HTTP::Post`, etc.
        def net_http_request_class(request)
          Net::HTTP.const_get(request.http_method.capitalize)
        rescue NameError
          msg = "`#{request.http_method}` is not a valid http verb"
          raise InvalidHttpVerbError, msg
        end

        # @param [Http::Request] request
        # @return [Hash] Returns a vanilla hash of headers to send with the
        #   HTTP request.
        def headers(request)
          # setting these to stop net/http from providing defaults
          headers = { 'content-type' => '', 'accept-encoding' => '' }
          request.headers.each_pair do |key, value|
            headers[key] = value
          end
          headers
        end

        # @param [Net::HTTP::Response] response
        # @return [Hash<String, String>]
        def extract_headers(response)
          response.to_hash.inject({}) do |headers, (k, v)|
            headers[k] = v.first
            headers
          end
        end

      end
    end
  end
end
