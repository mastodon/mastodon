# frozen_string_literal: true

module Mastodon
  module Middleware
    class SocketCleanup
      def initialize(app)
        @app = app
      end

      def call(env)
        @app.call(env)
      ensure
        clean_up_sockets!
      end

      private

      def clean_up_sockets!
        clean_up_redis_socket!
        clean_up_statsd_socket!
      end

      def clean_up_redis_socket!
        RedisConnection.pool.checkin if Thread.current[:redis]
        Thread.current[:redis] = nil
      end

      def clean_up_statsd_socket!
        Thread.current[:statsd_socket]&.close
        Thread.current[:statsd_socket] = nil
      end
    end
  end
end
