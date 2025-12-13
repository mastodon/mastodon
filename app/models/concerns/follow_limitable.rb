# frozen_string_literal: true

module FollowLimitable
  extend ActiveSupport::Concern

  included do
    validates_with FollowLimitValidator, on: :create, unless: :bypass_follow_limit

    attribute :bypass_follow_limit, :boolean, default: false
  end
end
