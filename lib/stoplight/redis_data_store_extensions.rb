# frozen_string_literal: true

# Restore compatibility with Redis < 6.2

module Stoplight
  module DataStore
    module RedisExtensions
      def query_failures(light, transaction: @redis)
        window_start = Time.now.to_i - light.window_size

        transaction.zrevrangebyscore(failures_key(light), Float::INFINITY, window_start)
      end
    end
  end
end

Stoplight::DataStore::Redis.prepend(Stoplight::DataStore::RedisExtensions)
