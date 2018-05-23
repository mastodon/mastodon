if defined?(Excon)
  module Excon
    class Socket
      alias_method :orig_connect, :connect
      def connect
        host = @data[:proxy] ? @data[:proxy][:host] : @data[:host]
        port = @data[:proxy] ? @data[:proxy][:port] : @data[:port]
        HttpLog.log_connection(host, port)
        orig_connect
      end

    end

    class Connection

      def _httplog_url(datum)
        "#{datum[:scheme]}://#{datum[:host]}:#{datum[:port]}#{datum[:path]}#{datum[:query]}"
      end

      alias_method :orig_request, :request
      def request(params, &block)
        result = nil
        bm = Benchmark.realtime do
          result = orig_request(params, &block)
        end

        datum = @data.merge(params)
        datum[:headers] = @data[:headers].merge(datum[:headers] || {})
        url = _httplog_url(datum)
  
        if HttpLog.url_approved?(url)
          HttpLog.log_compact(datum[:method], url, datum[:status] || result.status, bm)
          HttpLog.log_benchmark(bm)
        end
        result
      end

      alias_method :orig_request_call, :request_call
      def request_call(datum)
        url = _httplog_url(datum)

        if HttpLog.url_approved?(url)
          HttpLog.log_request(datum[:method], _httplog_url(datum))
          HttpLog.log_headers(datum[:headers])
          HttpLog.log_data(datum[:body])# if datum[:method] == :post
        end
        orig_request_call(datum)
      end

      alias_method :orig_response, :response
      def response(datum={})
        return orig_response(datum) unless HttpLog.url_approved?(_httplog_url(datum))

        bm = Benchmark.realtime do
          datum = orig_response(datum)
        end
        response = datum[:response]
        headers = response[:headers] || {}
        content_type = 
        HttpLog.log_status(response[:status])
        HttpLog.log_body(response[:body], headers['Content-Encoding'], headers['Content-Type'])
        datum
      end
    end
  end
end
