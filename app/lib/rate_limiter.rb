# frozen_string_literal: true

class RateLimiter
  include Redisable

  FAMILIES = {
    follows: {
      limit: 400,
      period: 24.hours.freeze,
    }.freeze,

    statuses: {
      limit: 300,
      period: 3.hours.freeze,
    }.freeze,

    reports: {
      limit: 400,
      period: 24.hours.freeze,
    }.freeze,
  }.freeze

  def initialize(by, options = {})
    @by     = by
    @family = options[:family]
  end

  def record!
    limits.each.with_index do |limit, index|
      count = redis.multi do |transaction|
        transaction.incr(limit[:key])
        transaction.expire(limit[:key], (limit[:period] - (last_epoch_time % limit[:period]) + 1).to_i)
      end.first

      if count.to_i > limit[:limit]
        limits.take(index).each { |earlier_limit| redis.decr(earlier_limit[:key]) }

        raise Mastodon::RateLimitExceededError
      end
    end
  end

  def rollback!
    redis.pipelined do |pipeline|
      limits.each { |limit| pipeline.decr(limit.key) }
    end
  end

  def to_headers(now = Time.now.utc)
    counts = redis.mget(limits.pluck(:key))
    remaining_attempts = limits.zip(counts).map { |limit, count| [limit[:limit] - (count || 0).to_i, 0].max }
    limit, remaining = limits.zip(remaining_attempts).min_by(&:second)

    {
      'X-RateLimit-Limit' => limit[:limit].to_s,
      'X-RateLimit-Remaining' => remaining.to_s,
      'X-RateLimit-Reset' => (now + (limit[:period] - (now.to_i % limit[:period]))).iso8601(6),
    }
  end

  private

  def limits
    @limits ||= [default_limit, Emergency::RateLimitAction.get_rate_limits_for(@family, @by, last_epoch_time)].flatten.compact
  end

  def default_limit
    {
      limit: FAMILIES[@family][:limit],
      period: FAMILIES[@family][:period].to_i,
      key: "rate_limit:#{@by.id}:#{@family}:#{(last_epoch_time / FAMILIES[@family][:period].to_i).to_i}",
    }
  end

  def last_epoch_time
    @last_epoch_time ||= Time.now.to_i
  end
end
