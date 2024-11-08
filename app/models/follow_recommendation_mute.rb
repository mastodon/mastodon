# frozen_string_literal: true

class FollowRecommendationMute < ApplicationRecord
  belongs_to :account
  belongs_to :target_account, class_name: 'Account'

  validates :target_account, uniqueness: { scope: :account_id }

  after_commit :invalidate_follow_recommendations_cache

  private

  def invalidate_follow_recommendations_cache
    Rails.cache.delete("follow_recommendations/#{account_id}")
  end
end
