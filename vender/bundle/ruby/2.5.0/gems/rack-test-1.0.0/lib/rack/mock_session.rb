module Rack
  class MockSession # :nodoc:
    attr_writer :cookie_jar
    attr_reader :default_host

    def initialize(app, default_host = Rack::Test::DEFAULT_HOST)
      @app = app
      @after_request = []
      @default_host = default_host
      @last_request = nil
      @last_response = nil
    end

    def after_request(&block)
      @after_request << block
    end

    def clear_cookies
      @cookie_jar = Rack::Test::CookieJar.new([], @default_host)
    end

    def set_cookie(cookie, uri = nil)
      cookie_jar.merge(cookie, uri)
    end

    def request(uri, env)
      env['HTTP_COOKIE'] ||= cookie_jar.for(uri)
      @last_request = Rack::Request.new(env)
      status, headers, body = @app.call(@last_request.env)

      @last_response = MockResponse.new(status, headers, body, env['rack.errors'].flush)
      body.close if body.respond_to?(:close)

      cookie_jar.merge(last_response.headers['Set-Cookie'], uri)

      @after_request.each(&:call)

      if @last_response.respond_to?(:finish)
        @last_response.finish
      else
        @last_response
      end
    end

    # Return the last request issued in the session. Raises an error if no
    # requests have been sent yet.
    def last_request
      raise Rack::Test::Error, 'No request yet. Request a page first.' unless @last_request
      @last_request
    end

    # Return the last response received in the session. Raises an error if
    # no requests have been sent yet.
    def last_response
      raise Rack::Test::Error, 'No response yet. Request a page first.' unless @last_response
      @last_response
    end

    def cookie_jar
      @cookie_jar ||= Rack::Test::CookieJar.new([], @default_host)
    end
  end
end
