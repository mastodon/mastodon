# frozen_string_literal: true

module SidekiqUniqueJobs
  module Unlockable
    module_function

    def unlock(item)
      return unless item[UNIQUE_DIGEST_KEY]
      unlock_by_key(item[UNIQUE_DIGEST_KEY], item[JID_KEY])
    end

    def unlock_by_key(unique_key, jid, redis_pool = nil)
      return false unless Scripts::ReleaseLock.execute(redis_pool, unique_key, jid)
      after_unlock(jid)
    end

    def after_unlock(jid)
      ensure_job_id_removed(jid)
    end

    def ensure_job_id_removed(jid)
      Sidekiq.redis { |conn| conn.hdel(SidekiqUniqueJobs::HASH_KEY, jid) }
    end

    def logger
      SidekiqUniqueJobs.logger
    end
  end
end
