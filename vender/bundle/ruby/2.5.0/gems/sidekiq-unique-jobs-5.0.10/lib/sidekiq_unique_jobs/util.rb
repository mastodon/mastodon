# frozen_string_literal: true

module SidekiqUniqueJobs
  module Util # rubocop:disable Metrics/ModuleLength
    COUNT             = 'COUNT'
    DEFAULT_COUNT     = 1_000
    EXPIRE_BATCH_SIZE = 100
    MATCH             = 'MATCH'
    KEYS_METHOD       = 'keys'
    SCAN_METHOD       = 'scan'
    SCAN_PATTERN      = '*'

    extend self # rubocop:disable Style/ModuleFunction

    def keys(pattern = SCAN_PATTERN, count = DEFAULT_COUNT)
      send("keys_by_#{redis_keys_method}", pattern, count)
    end

    def unique_key(jid)
      connection do |conn|
        conn.hget(SidekiqUniqueJobs::HASH_KEY, jid)
      end
    end

    def del(pattern = SCAN_PATTERN, count = 0, dry_run = true)
      raise ArgumentError, 'Please provide a number of keys to delete greater than zero' if count.zero?
      logger.debug { "Deleting keys by: #{pattern}" }
      keys, time = timed { keys(pattern, count) }
      logger.debug { "#{keys.size} matching keys found in #{time} sec." }
      keys = dry_run(keys)
      logger.debug { "#{keys.size} matching keys after post-processing" }
      unless dry_run
        logger.debug { "deleting #{keys}..." }
        _, time = timed { batch_delete(keys) }
        logger.debug { "Deleted in #{time} sec." }
      end
      keys.size
    end

    def unique_hash
      connection do |conn|
        conn.hgetall(SidekiqUniqueJobs::HASH_KEY)
      end
    end

    def expire # rubocop:disable Metrics/MethodLength
      removed_keys = {}
      connection do |conn|
        cursor = '0'
        loop do
          cursor, jobs = get_jobs(conn, cursor)
          jobs.each do |job_array|
            jid, unique_key = job_array

            next if conn.get(unique_key)
            conn.hdel(SidekiqUniqueJobs::HASH_KEY, jid)
            removed_keys[jid] = unique_key
          end

          break if cursor == '0'
        end
      end

      removed_keys
    end

    private

    def get_jobs(conn, cursor)
      conn.hscan(SidekiqUniqueJobs::HASH_KEY, [cursor, MATCH, SCAN_PATTERN, COUNT, EXPIRE_BATCH_SIZE])
    end

    def keys_by_scan(pattern, count)
      connection { |conn| conn.scan_each(match: prefix(pattern), count: count).to_a }
    end

    def keys_by_keys(pattern, _count)
      connection { |conn| conn.keys(prefix(pattern)).to_a }
    end

    def batch_delete(keys)
      connection do |conn|
        keys.each_slice(500) do |chunk|
          conn.pipelined do
            chunk.each do |key|
              conn.del key
            end
          end
        end
      end
    end

    def dry_run(keys, pattern = nil)
      return keys if pattern.nil?
      regex = Regexp.new(pattern)
      keys.select { |k| regex.match k }
    end

    def timed(&_block)
      start = Time.now
      result = yield
      elapsed = (Time.now - start).round(2)
      [result, elapsed]
    end

    def prefix_keys(keys)
      keys = Array(keys).flatten.compact
      keys.map { |key| prefix(key) }
    end

    def prefix(key)
      return key if unique_prefix.nil?
      return key if key.start_with?("#{unique_prefix}:")
      "#{unique_prefix}:#{key}"
    end

    def unique_prefix
      SidekiqUniqueJobs.config.unique_prefix
    end

    def connection(&block)
      SidekiqUniqueJobs.connection(&block)
    end

    def redis_version
      SidekiqUniqueJobs.redis_version
    end

    def redis_keys_method
      (redis_version >= '2.8') ? SCAN_METHOD : KEYS_METHOD
    end

    def logger
      SidekiqUniqueJobs.logger
    end
  end
end
