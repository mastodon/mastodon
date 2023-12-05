# frozen_string_literal: true

class ActivityTracker
  include Redisable

  EXPIRE_AFTER = 6.months.seconds

  def initialize(prefix, type)
    @prefix = prefix
    @type   = type
  end

  def add(value = 1, at_time = Time.now.utc)
    key = key_at(at_time)

    case @type
    when :basic
      redis.incrby(key, value)
    when :unique
      redis.pfadd(key, value)
    end

    redis.expire(key, EXPIRE_AFTER)
  end

  def get(start_at, end_at = Time.now.utc)
    (start_at.to_date...end_at.to_date).map do |date|
      key = key_at(date.to_time(:utc))

      value = case @type
              when :basic
                redis.get(key).to_i
              when :unique
                redis.pfcount(key)
              end

      [date, value]
    end
  end

  def sum(start_at, end_at = Time.now.utc)
    keys = (start_at.to_date...end_at.to_date).flat_map { |date| [key_at(date.to_time(:utc)), legacy_key_at(date)] }.uniq

    case @type
    when :basic
      redis.mget(*keys).sum(&:to_i)
    when :unique
      redis.pfcount(*keys)
    end
  end

  class << self
    def increment(prefix)
      new(prefix, :basic).add
    end

    def record(prefix, value)
      new(prefix, :unique).add(value)
    end
  end

  private

  def key_at(at_time)
    "#{@prefix}:#{at_time.beginning_of_day.to_i}"
  end

  def legacy_key_at(at_time)
    "#{@prefix}:#{at_time.to_date.cweek}"
  end
end
