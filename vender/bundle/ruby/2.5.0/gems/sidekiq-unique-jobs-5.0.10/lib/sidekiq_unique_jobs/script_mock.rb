# frozen_string_literal: true

require 'pathname'
require 'digest/sha1'

module SidekiqUniqueJobs
  module ScriptMock
    module_function

    extend SingleForwardable
    def_delegator :SidekiqUniqueJobs, :connection

    def call(file_name, redis_pool, options = {})
      send(file_name, redis_pool, options)
    end

    def acquire_lock(redis_pool, options = {})
      connection(redis_pool) do |conn|
        unique_key = options[:keys][0]
        job_id     = options[:argv][0]
        expires    = options[:argv][1].to_i
        stored_jid = conn.get(unique_key)

        return (stored_jid == job_id) ? 1 : 0 if stored_jid
        return 0 unless conn.set(unique_key, job_id, nx: true, ex: expires)

        conn.hsetnx(SidekiqUniqueJobs::HASH_KEY, job_id, unique_key)

        return 1
      end
    end

    def release_lock(redis_pool, options = {})
      connection(redis_pool) do |conn|
        unique_key = options[:keys][0]
        job_id     = options[:argv][0]
        stored_jid = conn.get(unique_key)

        return -1 unless stored_jid
        return 0 unless stored_jid == job_id || stored_jid == '2'

        conn.del(unique_key)
        conn.hdel(SidekiqUniqueJobs::HASH_KEY, job_id)

        return 1
      end
    end

    def synchronize(redis_pool, options = {})
      connection(redis_pool) do |conn|
        unique_key = options[:keys][0]
        time       = options[:argv][0].to_i
        expires    = options[:argv][1].to_f

        return 1 if conn.set(unique_key, time + expires, nx: true, ex: expires)

        stored_time = conn.get(unique_key)
        if stored_time && stored_time < time
          if conn.set(unique_key, time + expires, xx: true, ex: expires)
            return 1
          end
        end

        return 0
      end
    end
  end
  # rubocop:enable MethodLength
end
