# frozen_string_literal: true

module SidekiqUniqueJobs
  module Scripts
    class ReleaseLock
      extend Forwardable
      def_delegator SidekiqUniqueJobs, :logger

      def self.execute(redis_pool, unique_key, jid)
        new(redis_pool, unique_key, jid).execute
      end

      attr_reader :redis_pool, :unique_key, :jid

      def initialize(redis_pool, unique_key, jid)
        raise UniqueKeyMissing, 'unique_key is required' if unique_key.nil?
        raise JidMissing, 'jid is required' if jid.nil?

        @redis_pool    = redis_pool
        @unique_key    = unique_key
        @jid           = jid
      end

      def execute
        result = Scripts.call(:release_lock, redis_pool,
                              keys: [unique_key],
                              argv: [jid])

        handle_result(result)
      end

      def handle_result(result)
        case result
        when 1
          logger.debug { "successfully unlocked #{unique_key}" }
          true
        when 0
          logger.debug { "expiring lock #{unique_key} is not owned by #{jid}" }
          false
        when -1
          logger.debug { "#{unique_key} is not a known key" }
          false
        else
          raise UnexpectedValue, "failed to release lock : unexpected return value (#{result})"
        end
      end
    end
  end
end
