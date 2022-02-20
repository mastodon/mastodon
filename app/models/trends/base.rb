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
    Trends::Query.new(key_prefix, klass)
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

  # @param [Integer] id
  # @param [Float] score
  # @param [Hash<String, Boolean>] subsets
  def add_to_and_remove_from_subsets(id, score, subsets = {})
    subsets.each_key do |subset|
      key = [key_prefix, subset].compact.join(':')

      if score.positive? && subsets[subset]
        redis.zadd(key, score, id)
      else
        redis.zrem(key, id)
      end
    end
  end

  private

  def used_key(at_time)
    "#{key_prefix}:used:#{at_time.beginning_of_day.to_i}"
  end
end
