module OmniAuth
  module Test
    class PhonySession
      def initialize(app)
        @app = app
      end

      def call(env)
        @session ||= (env['rack.session'] || {})
        env['rack.session'] = @session
        @app.call(env)
      end
    end
  end
end
