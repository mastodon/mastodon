require 'stringio'
require 'uri'

module Seahorse
  module Client
    module Http
      class Request

        # @option options [URI::HTTP, URI::HTTPS] :endpoint (nil)
        # @option options [String] :http_method ('GET')
        # @option options [Headers] :headers (Headers.new)
        # @option options [Body] :body (StringIO.new)
        def initialize(options = {})
          self.endpoint = options[:endpoint]
          self.http_method = options[:http_method] || 'GET'
          self.headers = Headers.new(options[:headers] || {})
          self.body = options[:body]
        end

        # @return [String] The HTTP request method, e.g. `GET`, `PUT`, etc.
        attr_accessor :http_method

        # @return [Headers] The hash of request headers.
        attr_accessor :headers

        # @return [URI::HTTP, URI::HTTPS, nil]
        def endpoint
          @endpoint
        end

        # @param [String, URI::HTTP, URI::HTTPS, nil] endpoint
        def endpoint=(endpoint)
          endpoint = URI.parse(endpoint) if endpoint.is_a?(String)
          if endpoint.nil? or URI::HTTP === endpoint or URI::HTTPS === endpoint
            @endpoint = endpoint
          else
            msg = "invalid endpoint, expected URI::HTTP, URI::HTTPS, or nil, "
            msg << "got #{endpoint.inspect}"
            raise ArgumentError, msg
          end
        end

        # @return [IO]
        def body
          @body
        end

        # @return [String]
        def body_contents
          body.rewind
          contents = body.read
          body.rewind
          contents
        end

        # @param [#read, #size, #rewind] io
        def body=(io)
          @body =case io
            when nil then StringIO.new('')
            when String then StringIO.new(io)
            else io
          end
        end

      end
    end
  end
end
