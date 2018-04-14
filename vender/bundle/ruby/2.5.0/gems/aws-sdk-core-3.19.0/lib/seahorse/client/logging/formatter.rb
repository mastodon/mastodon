require 'pathname'

module Seahorse
  module Client
    # @deprecated Use Aws::Logging instead.
    # @api private
    module Logging

      # A log formatter receives a {Response} object and return
      # a log message as a string. When you construct a {Formatter}, you provide
      # a pattern string with substitutions.
      #
      #     pattern = ':operation :http_response_status_code :time'
      #     formatter = Seahorse::Client::Logging::Formatter.new(pattern)
      #     formatter.format(response)
      #     #=> 'get_bucket 200 0.0352'
      #
      # # Canned Formatters
      #
      # Instead of providing your own pattern, you can choose a canned log
      # formatter.
      #
      # * {Formatter.default}
      # * {Formatter.colored}
      # * {Formatter.short}
      #
      # # Pattern Substitutions
      #
      # You can put any of these placeholders into you pattern.
      #
      #   * `:client_class` - The name of the client class.
      #
      #   * `:operation` - The name of the client request method.
      #
      #   * `:request_params` - The user provided request parameters. Long
      #     strings are truncated/summarized if they exceed the
      #     {#max_string_size}.  Other objects are inspected.
      #
      #   * `:time` - The total time in seconds spent on the
      #     request.  This includes client side time spent building
      #     the request and parsing the response.
      #
      #   * `:retries` - The number of times a client request was retried.
      #
      #   * `:http_request_method` - The http request verb, e.g., `POST`,
      #     `PUT`, `GET`, etc.
      #
      #   * `:http_request_endpoint` - The request endpoint.  This includes
      #      the scheme, host and port, but not the path.
      #
      #   * `:http_request_scheme` - This is replaced by `http` or `https`.
      #
      #   * `:http_request_host` - The host name of the http request
      #     endpoint (e.g. 's3.amazon.com').
      #
      #   * `:http_request_port` - The port number (e.g. '443' or '80').
      #
      #   * `:http_request_headers` - The http request headers, inspected.
      #
      #   * `:http_request_body` - The http request payload.
      #
      #   * `:http_response_status_code` - The http response status
      #     code, e.g., `200`, `404`, `500`, etc.
      #
      #   * `:http_response_headers` - The http response headers, inspected.
      #
      #   * `:http_response_body` - The http response body contents.
      #
      #   * `:error_class`
      #
      #   * `:error_message`
      #
      class Formatter

        # @param [String] pattern The log format pattern should be a string
        #   and may contain substitutions.
        #
        # @option options [Integer] :max_string_size (1000) When summarizing
        #   request parameters, strings longer than this value will be
        #   truncated.
        #
        def initialize(pattern, options = {})
          @pattern = pattern
          @max_string_size = options[:max_string_size] || 1000
        end

        # @return [String]
        attr_reader :pattern

        # @return [Integer]
        attr_reader :max_string_size

        # Given a {Response}, this will format a log message and return it
        #   as a string.
        # @param [Response] response
        # @return [String]
        def format(response)
          pattern.gsub(/:(\w+)/) {|sym| send("_#{sym[1..-1]}", response) }
        end

        # @api private
        def eql?(other)
          other.is_a?(self.class) and other.pattern == self.pattern
        end
        alias :== :eql?

        private

        def method_missing(method_name, *args)
          if method_name.to_s.chars.first == '_'
            ":#{method_name.to_s[1..-1]}"
          else
            super
          end
        end

        def _client_class(response)
          response.context.client.class.name
        end

        def _operation(response)
          response.context.operation_name
        end

        def _request_params(response)
          summarize_hash(response.context.params)
        end

        def _time(response)
          duration = response.context[:logging_completed_at] -
            response.context[:logging_started_at]
          ("%.06f" % duration).sub(/0+$/, '')
        end

        def _retries(response)
          response.context.retries
        end

        def _http_request_endpoint(response)
          response.context.http_request.endpoint.to_s
        end

        def _http_request_scheme(response)
          response.context.http_request.endpoint.scheme
        end

        def _http_request_host(response)
          response.context.http_request.endpoint.host
        end

        def _http_request_port(response)
          response.context.http_request.endpoint.port.to_s
        end

        def _http_request_method(response)
          response.context.http_request.http_method
        end

        def _http_request_headers(response)
          response.context.http_request.headers.inspect
        end

        def _http_request_body(response)
          summarize_value(response.context.http_request.body_contents)
        end

        def _http_response_status_code(response)
          response.context.http_response.status_code.to_s
        end

        def _http_response_headers(response)
          response.context.http_response.headers.inspect
        end

        def _http_response_body(response)
          response.context.http_response.body.respond_to?(:rewind) ?
            summarize_value(response.context.http_response.body_contents) :
            ''
        end

        def _error_class(response)
          response.error ? response.error.class.name : ''
        end

        def _error_message(response)
          response.error ? response.error.message : ''
        end

        # @param [Hash] hash
        # @return [String]
        def summarize_hash(hash)
          hash.keys.first.is_a?(String) ?
            summarize_string_hash(hash) :
            summarize_symbol_hash(hash)
        end

        def summarize_symbol_hash(hash)
          hash.map do |key,v|
            "#{key}:#{summarize_value(v)}"
          end.join(",")
        end

        def summarize_string_hash(hash)
          hash.map do |key,v|
            "#{key.inspect}=>#{summarize_value(v)}"
          end.join(",")
        end

        # @param [Object] value
        # @return [String]
        def summarize_value value
          case value
          when String   then summarize_string(value)
          when Hash     then '{' + summarize_hash(value) + '}'
          when Array    then summarize_array(value)
          when File     then summarize_file(value.path)
          when Pathname then summarize_file(value)
          else value.inspect
          end
        end

        # @param [String] str
        # @return [String]
        def summarize_string str
          max = max_string_size
          if str.size > max
            "#<String #{str[0...max].inspect} ... (#{str.size} bytes)>"
          else
            str.inspect
          end
        end

        # Given the path to a file on disk, this method returns a summarized
        # inspecton string that includes the file size.
        # @param [String] path
        # @return [String]
        def summarize_file path
          "#<File:#{path} (#{File.size(path)} bytes)>"
        end

        # @param [Array] array
        # @return [String]
        def summarize_array array
          "[" + array.map{|v| summarize_value(v) }.join(",") + "]"
        end

        class << self

          # The default log format.
          #
          # @example A sample of the default format.
          #
          #     [ClientClass 200 0.580066 0 retries] list_objects(:bucket_name => 'bucket')
          #
          # @return [Formatter]
          #
          def default
            pattern = []
            pattern << "[:client_class"
            pattern << ":http_response_status_code"
            pattern << ":time"
            pattern << ":retries retries]"
            pattern << ":operation(:request_params)"
            pattern << ":error_class"
            pattern << ":error_message"
            Formatter.new(pattern.join(' ') + "\n")
          end

          # The short log format.  Similar to default, but it does not
          # inspect the request params or report on retries.
          #
          # @example A sample of the short format
          #
          #     [ClientClass 200 0.494532] list_buckets
          #
          # @return [Formatter]
          #
          def short
            pattern = []
            pattern << "[:client_class"
            pattern << ":http_response_status_code"
            pattern << ":time]"
            pattern << ":operation"
            pattern << ":error_class"
            Formatter.new(pattern.join(' ') + "\n")
          end

          # The default log format with ANSI colors.
          #
          # @example A sample of the colored format (sans the ansi colors).
          #
          #     [ClientClass 200 0.580066 0 retries] list_objects(:bucket_name => 'bucket')
          #
          # @return [Formatter]
          #
          def colored
            bold = "\x1b[1m"
            color = "\x1b[34m"
            reset = "\x1b[0m"
            pattern = []
            pattern << "#{bold}#{color}[:client_class"
            pattern << ":http_response_status_code"
            pattern << ":time"
            pattern << ":retries retries]#{reset}#{bold}"
            pattern << ":operation(:request_params)"
            pattern << ":error_class"
            pattern << ":error_message#{reset}"
            Formatter.new(pattern.join(' ') + "\n")
          end

        end

      end
    end
  end
end
