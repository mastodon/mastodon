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
    DURATIONS.each do |duration_type, duration|
      key = key_at(at_time, duration_type)
      redis.incrby(key, value)
      redis.expire(key, duration * RETENTION_FACTOR)
    end

    # TODO: trigger stuff
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
