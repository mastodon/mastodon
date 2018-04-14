module Faraday
  class Adapter
    # Sends requests to a Rack app.
    #
    # Examples
    #
    #   class MyRackApp
    #     def call(env)
    #       [200, {'Content-Type' => 'text/html'}, ["hello world"]]
    #     end
    #   end
    #
    #   Faraday.new do |conn|
    #     conn.adapter :rack, MyRackApp.new
    #   end
    class Rack < Faraday::Adapter
      dependency 'rack/test'

      # not prefixed with "HTTP_"
      SPECIAL_HEADERS = %w[ CONTENT_LENGTH CONTENT_TYPE ]

      def initialize(faraday_app, rack_app)
        super(faraday_app)
        mock_session = ::Rack::MockSession.new(rack_app)
        @session     = ::Rack::Test::Session.new(mock_session)
      end

      def call(env)
        super
        rack_env = {
          :method => env[:method],
          :input  => env[:body].respond_to?(:read) ? env[:body].read : env[:body],
          'rack.url_scheme' => env[:url].scheme
        }

        env[:request_headers].each do |name, value|
          name = name.upcase.tr('-', '_')
          name = "HTTP_#{name}" unless SPECIAL_HEADERS.include? name
          rack_env[name] = value
        end if env[:request_headers]

        timeout  = env[:request][:timeout] || env[:request][:open_timeout]
        response = if timeout
          Timer.timeout(timeout, Faraday::Error::TimeoutError) { execute_request(env, rack_env) }
        else
          execute_request(env, rack_env)
        end

        save_response(env, response.status, response.body, response.headers)
        @app.call env
      end

      def execute_request(env, rack_env)
        @session.request(env[:url].to_s, rack_env)
      end
    end
  end
end
