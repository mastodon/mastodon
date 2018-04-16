module Faraday
  class Adapter
    # Examples
    #
    #   test = Faraday::Connection.new do
    #     use Faraday::Adapter::Test do |stub|
    #       # simply define matcher to match the request
    #       stub.get '/resource.json' do
    #         # return static content
    #         [200, {'Content-Type' => 'application/json'}, 'hi world']
    #       end
    #       
    #       # response with content generated based on request
    #       stub.get '/showget' do |env|
    #         [200, {'Content-Type' => 'text/plain'}, env[:method].to_s]
    #       end
    #       
    #       # regular expression can be used as matching filter
    #       stub.get /\A\/items\/(\d+)\z/ do |env, meta|
    #         # in case regular expression is used an instance of MatchData can be received
    #         [200, {'Content-Type' => 'text/plain'}, "showing item: #{meta[:match_data][1]}"]
    #       end
    #     end
    #   end
    #   
    #   resp = test.get '/resource.json'
    #   resp.body # => 'hi world'
    #   
    #   resp = test.get '/showget'
    #   resp.body # => 'get'
    #   
    #   resp = test.get '/items/1'
    #   resp.body # => 'showing item: 1'
    #   
    #   resp = test.get '/items/2'
    #   resp.body # => 'showing item: 2'
    #

    class Test < Faraday::Adapter
      attr_accessor :stubs

      class Stubs
        class NotFound < StandardError
        end

        def initialize
          # {:get => [Stub, Stub]}
          @stack, @consumed = {}, {}
          yield(self) if block_given?
        end

        def empty?
          @stack.empty?
        end

        def match(request_method, host, path, headers, body)
          return false if !@stack.key?(request_method)
          stack = @stack[request_method]
          consumed = (@consumed[request_method] ||= [])

          stub, meta = matches?(stack, host, path, headers, body)
          if stub
            consumed << stack.delete(stub)
            return stub, meta
          end
          matches?(consumed, host, path, headers, body)
        end

        def get(path, headers = {}, &block)
          new_stub(:get, path, headers, &block)
        end

        def head(path, headers = {}, &block)
          new_stub(:head, path, headers, &block)
        end

        def post(path, body=nil, headers = {}, &block)
          new_stub(:post, path, headers, body, &block)
        end

        def put(path, body=nil, headers = {}, &block)
          new_stub(:put, path, headers, body, &block)
        end

        def patch(path, body=nil, headers = {}, &block)
          new_stub(:patch, path, headers, body, &block)
        end

        def delete(path, headers = {}, &block)
          new_stub(:delete, path, headers, &block)
        end

        def options(path, headers = {}, &block)
          new_stub(:options, path, headers, &block)
        end

        # Raises an error if any of the stubbed calls have not been made.
        def verify_stubbed_calls
          failed_stubs = []
          @stack.each do |method, stubs|
            unless stubs.size == 0
              failed_stubs.concat(stubs.map {|stub|
                "Expected #{method} #{stub}."
              })
            end
          end
          raise failed_stubs.join(" ") unless failed_stubs.size == 0
        end

        protected

        def new_stub(request_method, path, headers = {}, body=nil, &block)
          normalized_path, host =
            if path.is_a?(Regexp)
              path
            else
              [Faraday::Utils.normalize_path(path), Faraday::Utils.URI(path).host]
            end

          (@stack[request_method] ||= []) << Stub.new(host, normalized_path, headers, body, block)
        end

        def matches?(stack, host, path, headers, body)
          stack.each do |stub|
            match_result, meta = stub.matches?(host, path, headers, body)
            return stub, meta if match_result
          end
          nil
        end
      end

      class Stub < Struct.new(:host, :path, :params, :headers, :body, :block)
        def initialize(host, full, headers, body, block)
          path, query = full.respond_to?(:split) ? full.split("?") : full
          params = query ?
            Faraday::Utils.parse_nested_query(query) :
            {}
          super(host, path, params, headers, body, block)
        end

        def matches?(request_host, request_uri, request_headers, request_body)
          request_path, request_query = request_uri.split('?')
          request_params = request_query ?
            Faraday::Utils.parse_nested_query(request_query) :
            {}
          # meta is a hash use as carrier
          # that will be yielded to consumer block
          meta = {}
          return (host.nil? || host == request_host) &&
            path_match?(request_path, meta) &&
            params_match?(request_params) &&
            (body.to_s.size.zero? || request_body == body) &&
            headers_match?(request_headers), meta
        end

        def path_match?(request_path, meta)
          if path.is_a? Regexp
            !!(meta[:match_data] = path.match(request_path))
          else
            path == request_path
          end
        end

        def params_match?(request_params)
          params.keys.all? do |key|
            request_params[key] == params[key]
          end
        end

        def headers_match?(request_headers)
          headers.keys.all? do |key|
            request_headers[key] == headers[key]
          end
        end

        def to_s
          "#{path} #{body}"
        end
      end

      def initialize(app, stubs=nil, &block)
        super(app)
        @stubs = stubs || Stubs.new
        configure(&block) if block
      end

      def configure
        yield(stubs)
      end

      def call(env)
        super
        host = env[:url].host
        normalized_path = Faraday::Utils.normalize_path(env[:url])
        params_encoder = env.request.params_encoder || Faraday::Utils.default_params_encoder

        stub, meta = stubs.match(env[:method], host, normalized_path, env.request_headers, env[:body])
        if stub
          env[:params] = (query = env[:url].query) ?
            params_encoder.decode(query) : {}
          block_arity = stub.block.arity
          status, headers, body = (block_arity >= 0) ?
            stub.block.call(*[env, meta].take(block_arity)) :
            stub.block.call(env, meta)
          save_response(env, status, body, headers)
        else
          raise Stubs::NotFound, "no stubbed request for #{env[:method]} #{normalized_path} #{env[:body]}"
        end
        @app.call(env)
      end
    end
  end
end
