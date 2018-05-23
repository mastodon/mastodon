# frozen_string_literal: true

module SidekiqUniqueJobs
  module Lock
    class WhileExecuting
      def self.synchronize(item, redis_pool = nil)
        new(item, redis_pool).synchronize { yield }
      end

      def initialize(item, redis_pool = nil)
        @item = item
        @redis_pool = redis_pool
        @unique_digest = "#{create_digest}:run"
        @mutex = Mutex.new
      end

      def synchronize
        @mutex.synchronize do
          sleep 0.1 until locked?
          yield
        end
      rescue Sidekiq::Shutdown
        logger.fatal { "the unique_key: #{@unique_digest} needs to be unlocked manually" }
        raise
      ensure
        SidekiqUniqueJobs.connection(@redis_pool) { |conn| conn.del @unique_digest }
      end

      def locked?
        Scripts.call(:synchronize, @redis_pool,
                     keys: [@unique_digest],
                     argv: [Time.now.to_i, max_lock_time]) == 1
      end

      def max_lock_time
        @max_lock_time ||= RunLockTimeoutCalculator.for_item(@item).seconds
      end

      def execute(_callback)
        synchronize do
          yield
        end
      end

      def create_digest
        @unique_digest ||= @item[UNIQUE_DIGEST_KEY]
        @unique_digest ||= SidekiqUniqueJobs::UniqueArgs.digest(@item)
      end
    end
  end
end
