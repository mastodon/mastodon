# frozen_string_literal: true

module FollowLimitable
  extend ActiveSupport::Concern

  included do
    validates_with FollowLimitValidator, on: :create, unless: :bypass_follow_limit?
  end

  def bypass_follow_limit=(value)
    @bypass_follow_limit = value
  end

  def bypass_follow_limit?
    @bypass_follow_limit
  end
end
