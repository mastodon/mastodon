module Faraday
  class Request::Instrumentation < Faraday::Middleware
    class Options < Faraday::Options.new(:name, :instrumenter)
      def name
        self[:name] ||= 'request.faraday'
      end

      def instrumenter
        self[:instrumenter] ||= ActiveSupport::Notifications
      end
    end

    # Public: Instruments requests using Active Support.
    #
    # Measures time spent only for synchronous requests.
    #
    # Examples
    #
    #   ActiveSupport::Notifications.subscribe('request.faraday') do |name, starts, ends, _, env|
    #     url = env[:url]
    #     http_method = env[:method].to_s.upcase
    #     duration = ends - starts
    #     $stderr.puts '[%s] %s %s (%.3f s)' % [url.host, http_method, url.request_uri, duration]
    #   end
    def initialize(app, options = nil)
      super(app)
      @name, @instrumenter = Options.from(options).values_at(:name, :instrumenter)
    end

    def call(env)
      @instrumenter.instrument(@name, env) do
        @app.call(env)
      end
    end
  end
end
