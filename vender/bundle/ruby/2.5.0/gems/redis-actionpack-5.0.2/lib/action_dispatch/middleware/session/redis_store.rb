require 'redis-store'
require 'redis-rack'
require 'action_dispatch/middleware/session/abstract_store'

module ActionDispatch
  module Session
    class RedisStore < Rack::Session::Redis
      include Compatibility
      include StaleSessionCheck
      include SessionObject

      def initialize(app, options = {})
        options = options.dup
        options[:redis_server] ||= options[:servers]
        super
      end

      private

      def set_cookie(env, session_id, cookie)
        if env.is_a? ActionDispatch::Request
          request = env
        else
          request = ActionDispatch::Request.new(env)
        end
        request.cookie_jar[key] = cookie.merge(cookie_options)
      end

      def cookie_options
        @default_options.slice(:httponly, :secure)
      end
    end
  end
end
