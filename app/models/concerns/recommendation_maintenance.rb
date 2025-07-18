# frozen_string_literal: true

module RecommendationMaintenance
  extend ActiveSupport::Concern

  FOLLOW_RECOMMENDATIONS_SCOPE = 'follow_recommendations'

  included do
    after_commit :invalidate_follow_recommendations_cache
  end

  private

  def invalidate_follow_recommendations_cache
    Rails.cache.delete(follow_recommendations_cache_key)
  end

  def follow_recommendations_cache_key
    [FOLLOW_RECOMMENDATIONS_SCOPE, account_id].join('/')
  end
end
