if defined?(::HTTP::Client) && defined?(::HTTP::Connection)
  module ::HTTP
    class Client

      #
      request_method = respond_to?('make_request') ? 'make_request' : 'perform'
      orig_request_method = "orig_#{request_method}"
      alias_method(orig_request_method, request_method) unless method_defined?(orig_request_method)

      define_method request_method do |req, options|

        log_enabled = HttpLog.url_approved?(req.uri)

        if log_enabled
          HttpLog.log_request(req.verb, req.uri)
          HttpLog.log_headers(req.headers.to_h)
          HttpLog.log_data(req.body) #if req.verb == :post
        end

        bm = Benchmark.realtime do
          @response = send(orig_request_method, req, options)
        end

        if log_enabled
          headers = @response.headers
          HttpLog.log_compact(req.verb, req.uri, @response.code, bm)
          HttpLog.log_status(@response.code)
          HttpLog.log_benchmark(bm)
          HttpLog.log_headers(@response.headers.to_h)
          HttpLog.log_body(@response.body, headers['Content-Encoding'], headers['Content-Type'])
        end

        @response
      end
    end

    class Connection
      alias_method(:orig_initialize, :initialize) unless method_defined?(:orig_initialize)

      def initialize(req, options)
        HttpLog.log_connection(req.uri.host, req.uri.port) if HttpLog.url_approved?(req.uri)
        orig_initialize(req, options)
      end
    end
  end
end
