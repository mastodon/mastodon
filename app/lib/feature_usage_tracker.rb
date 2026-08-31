# frozen_string_literal: true

class FeatureUsageTracker
  include Redisable

  FEATURES = %i(
    follow
  ).freeze

  REF_VALUES = %w(
    author_attribution
    collection
    featured_account
    hover_card
    inline_suggestions
    onboarding
    profile
    search
    status
    suggestions
  ).freeze

  EXPIRE_AFTER = 6.months.seconds

  def self.for(feature)
    raise ArgumentError unless FEATURES.include?(feature)

    new(feature)
  end

  def initialize(feature)
    @feature = feature
  end

  def increment(ref)
    ref = nil unless REF_VALUES.include?(ref)
    key = key_at(Time.now.utc)

    with_redis do |redis|
      redis.hincrby(key, ref || 'unknown', 1)
      redis.expire(key, EXPIRE_AFTER)
    end
  end

  private

  def key_at(at_time)
    "activity:feature_usage:#{@feature}:#{at_time.beginning_of_day.to_i}"
  end
end
