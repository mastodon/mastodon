require 'uri'

module Aws
  module Sigv4
    class Request

      # @option options [required, String] :http_method
      # @option options [required, HTTP::URI, HTTPS::URI, String] :endpoint
      # @option options [Hash<String,String>] :headers ({})
      # @option options [String, IO] :body ('')
      def initialize(options = {})
        @http_method = nil
        @endpoint = nil
        @headers = {}
        @body = ''
        options.each_pair do |attr_name, attr_value|
          send("#{attr_name}=", attr_value)
        end
      end

      # @param [String] http_method One of 'GET', 'PUT', 'POST', 'DELETE', 'HEAD', or 'PATCH'
      def http_method=(http_method)
        @http_method = http_method
      end

      # @return [String] One of 'GET', 'PUT', 'POST', 'DELETE', 'HEAD', or 'PATCH'
      def http_method
        @http_method
      end

      # @param [String, HTTP::URI, HTTPS::URI] endpoint
      def endpoint=(endpoint)
        @endpoint = URI.parse(endpoint.to_s)
      end

      # @return [HTTP::URI, HTTPS::URI]
      def endpoint
        @endpoint
      end

      # @param [Hash] headers
      def headers=(headers)
        @headers = headers
      end

      # @return [Hash<String,String>]
      def headers
        @headers
      end

      # @param [String, IO] body
      def body=(body)
        @body = body
      end

      # @return [String, IO]
      def body
        @body
      end

    end
  end
end
