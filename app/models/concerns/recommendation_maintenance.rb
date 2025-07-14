# frozen_string_literal: true

module RecommendationMaintenance
  extend ActiveSupport::Concern

  included do
    after_commit :invalidate_follow_recommendations_cache
  end

  private

  def invalidate_follow_recommendations_cache
    Rails.cache.delete("follow_recommendations/#{account_id}")
  end
end
