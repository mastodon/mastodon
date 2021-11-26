# frozen_string_literal: true

class Trends::Base
  include Redisable

  def register(_status)
    raise NotImplementedError
  end

  def add(*)
    raise NotImplementedError
  end

  def refresh(*)
    raise NotImplementedError
  end

  def request_review
    raise NotImplementedError
  end

  def get(*)
    raise NotImplementedError
  end

  def score(id)
    redis.zscore("#{key_prefix}:all", id) || 0
  end

  def rank(id)
    redis.zrevrank("#{key_prefix}:allowed", id)
  end

  def currently_trending_ids(allowed, limit)
    redis.zrevrange(allowed ? "#{key_prefix}:allowed" : "#{key_prefix}:all", 0, limit.positive? ? limit - 1 : limit).map(&:to_i)
  end

  protected

  def key_prefix
    raise NotImplementedError
  end

  def recently_used_ids(at_time = Time.now.utc)
    redis.smembers(used_key(at_time)).map(&:to_i)
  end

  def record_used_id(id, at_time = Time.now.utc)
    redis.sadd(used_key(at_time), id)
    redis.expire(used_key(at_time), 1.day.seconds)
  end

  def trim_older_items
    redis.zremrangebyscore("#{key_prefix}:all", '-inf', '(1')
    redis.zremrangebyscore("#{key_prefix}:allowed", '-inf', '(1')
  end

  def score_at_rank(rank)
    redis.zrevrange("#{key_prefix}:allowed", 0, rank, with_scores: true).last&.last || 0
  end

  private

  def used_key(at_time)
    "#{key_prefix}:used:#{at_time.beginning_of_day.to_i}"
  end
end
