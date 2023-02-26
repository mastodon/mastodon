# frozen_string_literal: true

class DeliveryStatsTracker
  include Redisable

  def initialize(host)
    @host = host
  end

  def track_success!
    redis.incr(hourly_success_count_key(Time.now))
  end

  def track_failure!
    redis.incr(hourly_failure_count_key(Time.now))
  end

  def hourly_delivery_histories(start_time, end_time = Time.now)
    period = 1.hour
    start_time = start_time.beginning_of_hour
    end_time = (end_time + period).beginning_of_hour

    stats = ((end_time - start_time).to_i / period).times.map do |i|
      time = start_time + i * period
      success_count = redis.get(hourly_success_count_key(time)).to_i
      failure_count = redis.get(hourly_failure_count_key(time)).to_i
      StatRecord.new(time, success_count, failure_count)
    end
  end

  class StatRecord < Struct.new(:time, :success_count, :failure_count)
  end

  private

  def format_time(time)
    time.utc.strftime("%Y%m%dT%H")
  end

  def hourly_success_count_key(time)
    "delivery_stats:#{@host}:success:#{format_time(time)}"
  end

  def hourly_failure_count_key(time)
    "delivery_stats:#{@host}:failure:#{format_time(time)}"
  end
end
