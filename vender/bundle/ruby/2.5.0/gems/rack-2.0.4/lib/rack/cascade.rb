module Rack
  # Rack::Cascade tries a request on several apps, and returns the
  # first response that is not 404 or 405 (or in a list of configurable
  # status codes).

  class Cascade
    NotFound = [404, {CONTENT_TYPE => "text/plain"}, []]

    attr_reader :apps

    def initialize(apps, catch=[404, 405])
      @apps = []; @has_app = {}
      apps.each { |app| add app }

      @catch = {}
      [*catch].each { |status| @catch[status] = true }
    end

    def call(env)
      result = NotFound

      last_body = nil

      @apps.each do |app|
        # The SPEC says that the body must be closed after it has been iterated
        # by the server, or if it is replaced by a middleware action. Cascade
        # replaces the body each time a cascade happens. It is assumed that nil
        # does not respond to close, otherwise the previous application body
        # will be closed. The final application body will not be closed, as it
        # will be passed to the server as a result.
        last_body.close if last_body.respond_to? :close

        result = app.call(env)
        last_body = result[2]
        break unless @catch.include?(result[0].to_i)
      end

      result
    end

    def add(app)
      @has_app[app] = true
      @apps << app
    end

    def include?(app)
      @has_app.include? app
    end

    alias_method :<<, :add
  end
end
