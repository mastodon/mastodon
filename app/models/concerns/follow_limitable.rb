# frozen_string_literal: true

module FollowLimitable
  extend ActiveSupport::Concern

  included do
    validates_with FollowLimitValidator, on: :create, unless: :bypass_follow_limit

    attribute :bypass_follow_limit, :boolean, default: false

    rate_limit by: :account, family: :follows

    after_commit :invalidate_follow_recommendations_cache
  end

  private

  def invalidate_follow_recommendations_cache
    Rails.cache.delete("follow_recommendations/#{account_id}")
  end
end
