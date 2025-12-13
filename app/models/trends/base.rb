# frozen_string_literal: true

class Trends::Base
  include Redisable
  include LanguagesHelper

  class_attribute :default_options

  attr_reader :options

  # @param [Hash] options
  # @option options [Integer] :threshold Minimum amount of uses by unique accounts to begin calculating the score
  # @option options [Integer] :review_threshold Minimum rank (lower = better) before requesting a review
  # @option options [ActiveSupport::Duration] :max_score_cooldown For this amount of time, the peak score (if bigger than current score) is decayed-from
  # @option options [ActiveSupport::Duration] :max_score_halflife How quickly a peak score decays
  def initialize(options = {})
    @options = self.class.default_options.merge(options)
  end

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

  def query
    Trends::Query.new(klass)
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

  private

  def used_key(at_time)
    "#{key_prefix}:used:#{at_time.beginning_of_day.to_i}"
  end
end
