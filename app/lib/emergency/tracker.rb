# frozen_string_literal: true

class Emergency::Tracker
  include Redisable

  DURATIONS = {
    minute: 1.minute.to_i,
    hour: 1.hour.to_i,
    day: 1.day.to_i,
  }.freeze

  RETENTION_FACTOR = 5

  def initialize(prefix)
    @prefix = prefix
  end

  def add(value = 1, at_time = Time.now.utc)
    counts = DURATIONS.to_h do |duration_type, duration|
      key = key_at(at_time, duration_type)
      count = redis.multi do |transaction|
        transaction.incrby(key, value)
        transaction.expire(key, duration * RETENTION_FACTOR)
      end.first
      [duration_type, count]
    end

    Emergency::Trigger.process_event(@prefix, at_time, counts)
  end

  class << self
    def increment(prefix)
      new(prefix).add
    end
  end

  private

  def key_at(at_time, duration_type)
    subkey = begin
      case duration_type
      when :minute
        at_time.beginning_of_minute.to_i
      when :hour
        at_time.beginning_of_hour.to_i
      when :day
        at_time.beginning_of_day.to_i
      end
    end

    "emergency/tracking:#{@prefix}:#{duration_type}:#{subkey}"
  end
end
