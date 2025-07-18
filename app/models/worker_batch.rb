# frozen_string_literal: true

class WorkerBatch
  include Redisable

  TTL = 3600

  def initialize(id = nil)
    @id = id || SecureRandom.hex(12)
  end

  attr_reader :id

  # Connect the batch with an async refresh. When the number of processed jobs
  # passes the given threshold, the async refresh will be marked as finished.
  # @param [String] async_refresh_key
  # @param [Float] threshold
  def connect(async_refresh_key, threshold: 1.0)
    redis.hset(key, { 'async_refresh_key' => async_refresh_key, 'threshold' => threshold })
  end

  # Add jobs to the batch. Usually when the batch is created.
  # @param [Array<String>] jids
  def add_jobs(jids)
    if jids.blank?
      async_refresh_key = redis.hget(key, 'async_refresh_key')

      if async_refresh_key.present?
        async_refresh = AsyncRefresh.new(async_refresh_key)
        async_refresh.finish!
      end

      return
    end

    redis.multi do |pipeline|
      pipeline.sadd(key('jobs'), jids)
      pipeline.expire(key('jobs'), TTL)
      pipeline.hincrby(key, 'pending', jids.size)
      pipeline.expire(key, TTL)
    end
  end

  # Remove a job from the batch, such as when it's been processed or it has failed.
  # @param [String] jid
  def remove_job(jid)
    _, pending, processed, async_refresh_key, threshold = redis.multi do |pipeline|
      pipeline.srem(key('jobs'), jid)
      pipeline.hincrby(key, 'pending', -1)
      pipeline.hincrby(key, 'processed', 1)
      pipeline.hget(key, 'async_refresh_key')
      pipeline.hget(key, 'threshold')
    end

    if async_refresh_key.present?
      async_refresh = AsyncRefresh.new(async_refresh_key)
      async_refresh.increment_result_count(by: 1)
      async_refresh.finish! if pending.zero? || processed >= threshold.to_f * (processed + pending)
    end
  end

  # Get pending jobs.
  # @returns [Array<String>]
  def jobs
    redis.smembers(key('jobs'))
  end

  # Inspect the batch.
  # @returns [Hash]
  def info
    redis.hgetall(key)
  end

  private

  def key(suffix = nil)
    "worker_batch:#{@id}#{":#{suffix}" if suffix}"
  end
end
