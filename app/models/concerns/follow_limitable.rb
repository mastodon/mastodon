# frozen_string_literal: true

module FollowLimitable
  extend ActiveSupport::Concern

  included do
    rate_limit by: :account, family: :follows

    attribute :bypass_follow_limit, :boolean, default: false
    validates_with FollowLimitValidator, on: :create, unless: :bypass_follow_limit

    before_validation :set_uri, only: :create, unless: :uri?

    after_commit :invalidate_follow_recommendations_cache
  end

  def local?
    false # Force uri_for to use uri attribute
  end

  private

  def set_uri
    self.uri = ActivityPub::TagManager.instance.generate_uri_for(self)
  end

  def invalidate_follow_recommendations_cache
    Rails.cache.delete("follow_recommendations/#{account_id}")
  end
end
