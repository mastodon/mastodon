# frozen_string_literal: true

module SidekiqUniqueJobs
  module Scripts
    class AcquireLock
      extend Forwardable
      def_delegator SidekiqUniqueJobs, :logger

      def self.execute(redis_pool, unique_key, jid, max_lock_time)
        new(redis_pool, unique_key, jid, max_lock_time).execute
      end

      attr_reader :redis_pool, :unique_key, :jid, :max_lock_time

      def initialize(_redis_pool, unique_key, jid, max_lock_time)
        raise UniqueKeyMissing, 'unique_key is required' if unique_key.nil?
        raise JidMissing, 'jid is required' if jid.nil?
        raise MaxLockTimeMissing, 'max_lock_time is required' if max_lock_time.nil?

        @unique_key    = unique_key
        @jid           = jid
        @max_lock_time = max_lock_time
      end

      def execute
        result = Scripts.call(:acquire_lock, redis_pool,
                              keys: [unique_key],
                              argv: [jid, max_lock_time])

        handle_result(result)
      end

      def handle_result(result)
        case result
        when 1
          logger.debug { "successfully acquired lock #{unique_key} for #{max_lock_time} seconds" }
          true
        when 0
          logger.debug { "failed to acquire lock for #{unique_key}" }
          false
        else
          raise UnexpectedValue, "failed to acquire lock : unexpected return value (#{result})"
        end
      end
    end
  end
end
