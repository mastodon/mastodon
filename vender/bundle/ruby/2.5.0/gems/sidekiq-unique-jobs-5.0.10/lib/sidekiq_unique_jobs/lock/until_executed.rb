# frozen_string_literal: true

module SidekiqUniqueJobs
  module Lock
    class UntilExecuted
      OK ||= 'OK'

      include SidekiqUniqueJobs::Unlockable

      extend Forwardable
      def_delegators :Sidekiq, :logger

      def initialize(item, redis_pool = nil)
        @item = item
        @redis_pool = redis_pool
      end

      def execute(callback, &blk)
        operative = true
        send(:after_yield_yield, &blk)
      rescue Sidekiq::Shutdown
        operative = false
        raise
      ensure
        if operative && unlock(:server)
          callback.call
        else
          logger.fatal { "the unique_key: #{unique_key} needs to be unlocked manually" }
        end
      end

      def unlock(scope)
        unless [:server, :api, :test].include?(scope)
          raise ArgumentError, "#{scope} middleware can't #{__method__} #{unique_key}"
        end

        unlock_by_key(unique_key, item[JID_KEY], redis_pool)
      end

      def lock(scope)
        if scope.to_sym != :client
          raise ArgumentError, "#{scope} middleware can't #{__method__} #{unique_key}"
        end

        Scripts::AcquireLock.execute(
          redis_pool,
          unique_key,
          item[JID_KEY],
          max_lock_time,
        )
      end
      # rubocop:enable MethodLength

      def unique_key
        @unique_key ||= UniqueArgs.digest(item)
      end

      def max_lock_time
        @max_lock_time ||= QueueLockTimeoutCalculator.for_item(item).seconds
      end

      def after_yield_yield
        yield
      end

      private

      attr_reader :item, :redis_pool
    end
  end
end
