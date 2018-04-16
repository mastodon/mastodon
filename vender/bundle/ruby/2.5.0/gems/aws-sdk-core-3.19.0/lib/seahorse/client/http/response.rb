module Seahorse
  module Client
    module Http
      class Response

        # @option options [Integer] :status_code (0)
        # @option options [Headers] :headers (Headers.new)
        # @option options [IO] :body (StringIO.new)
        def initialize(options = {})
          @status_code = options[:status_code] || 0
          @headers = options[:headers] || Headers.new
          @body = options[:body] || StringIO.new
          @listeners = Hash.new { |h,k| h[k] = [] }
          @complete = false
          @done = nil
          @error = nil
        end

        # @return [Integer] Returns `0` if the request failed to generate
        #   any response.
        attr_accessor :status_code

        # @return [Headers]
        attr_accessor :headers

        # @return [StandardError, nil]
        attr_reader :error

        # @return [IO]
        def body
          @body
        end

        # @param [#read, #size, #rewind] io
        def body=(io)
          @body = case io
            when nil then StringIO.new('')
            when String then StringIO.new(io)
            else io
          end
        end

        # @return [String]
        def body_contents
          body.rewind
          contents = body.read
          body.rewind
          contents
        end

        # @param [Integer] status_code
        # @param [Hash<String,String>] headers
        def signal_headers(status_code, headers)
          @status_code = status_code
          @headers = Headers.new(headers)
          emit(:headers, @status_code, @headers)
        end

        # @param [string] chunk
        def signal_data(chunk)
          unless chunk == ''
            @body.write(chunk)
            emit(:data, chunk)
          end
        end

        # Completes the http response.
        #
        # @example Completing the response in a singal call
        #
        #     http_response.signal_done(
        #       status_code: 200,
        #       headers: {},
        #       body: ''
        #     )
        #
        # @example Complete the response in parts
        #
        #     # signal headers straight-way
        #     http_response.signal_headers(200, {})
        #
        #     # signal data as it is received from the socket
        #     http_response.signal_data("...")
        #     http_response.signal_data("...")
        #     http_response.signal_data("...")
        #
        #     # signal done once the body data is all written
        #     http_response.signal_done
        #
        # @overload signal_done()
        #
        # @overload signal_done(options = {})
        #   @option options [required, Integer] :status_code
        #   @option options [required, Hash] :headers
        #   @option options [required, String] :body
        #
        def signal_done(options = {})
          if options.keys.sort == [:body, :headers, :status_code]
            signal_headers(options[:status_code], options[:headers])
            signal_data(options[:body])
            signal_done
          elsif options.empty?
            @body.rewind if @body.respond_to?(:rewind)
            @done = true
            emit(:done)
          else
            msg = "options must be empty or must contain :status_code, :headers, "
            msg << "and :body"
            raise ArgumentError, msg
          end
        end

        # @param [StandardError] networking_error
        def signal_error(networking_error)
          @error = networking_error
          signal_done
        end

        def on_headers(status_code_range = nil, &block)
          @listeners[:headers] << listener(status_code_range, Proc.new)
        end

        def on_data(&callback)
          @listeners[:data] << Proc.new
        end

        def on_done(status_code_range = nil, &callback)
          listener = listener(status_code_range, Proc.new)
          if @done
            listener.call
          else
            @listeners[:done] << listener
          end
        end

        def on_success(status_code_range = 200..599, &callback)
          on_done(status_code_range) do
            unless @error
              yield
            end
          end
        end

        def on_error(&callback)
          on_done(0..599) do
            if @error
              yield(@error)
            end
          end
        end

        def reset
          @status_code = 0
          @headers.clear
          @body.truncate(0)
          @error = nil
        end

        private

        def listener(range, callback)
          range = range..range if Integer === range
          if range
            lambda do |*args|
              if range.include?(@status_code)
                callback.call(*args)
              end
            end
          else
            callback
          end
        end

        def emit(event_name, *args)
          @listeners[event_name].each { |listener| listener.call(*args) }
        end

      end
    end
  end
end
