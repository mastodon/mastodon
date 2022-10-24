# frozen_string_literal: true

module ArgumentDeduplication
  class Argument
    def self.from_value(value)
      new(Digest::SHA256.base64digest(value), value)
    end

    attr_reader :content_hash, :value

    def initialize(content_hash, value)
      @content_hash = content_hash
      @value = value
    end

    def push!
      with_redis do |redis|
        redis.multi do |transaction|
          transaction.set("#{PREFIX}:value:#{content_hash}", value, ex: TTL)
          transaction.incr("#{PREFIX}:refcount:#{content_hash}")
          transaction.expire("#{PREFIX}:refcount:#{content_hash}", TTL)
        end
      end
    end

    def pop!
      with_redis do |redis|
        redis.decr("#{PREFIX}:refcount:#{content_hash}")

        redis.watch("#{PREFIX}:refcount:#{content_hash}") do
          if redis.get("#{PREFIX}:refcount:#{content_hash}").to_i <= 0
            redis.multi do |transaction|
              transaction.del("#{PREFIX}:refcount:#{content_hash}")
              transaction.del("#{PREFIX}:value:#{content_hash}")
            end
          else
            redis.unwatch
          end
        end
      end
    end

    private

    def with_redis(&block)
      Sidekiq.redis(&block)
    end
  end
end
