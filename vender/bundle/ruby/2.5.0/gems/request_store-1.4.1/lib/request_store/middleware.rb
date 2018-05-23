require 'rack/body_proxy'

# A middleware that ensures the RequestStore stays around until
# the last part of the body is rendered. This is useful when
# using streaming.
#
# Uses Rack::BodyProxy, adapted from Rack::Lock's usage of the
# same pattern.

module RequestStore
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      RequestStore.begin!

      response = @app.call(env)

      returned = response << Rack::BodyProxy.new(response.pop) do
        RequestStore.end!
        RequestStore.clear!
      end
    ensure
      unless returned
        RequestStore.end!
        RequestStore.clear!
      end
    end
  end
end
