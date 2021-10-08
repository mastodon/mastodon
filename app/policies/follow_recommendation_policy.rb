# frozen_string_literal: true

class FollowRecommendationPolicy < ApplicationPolicy
  def show?
    staff?
  end

  def suppress?
    staff?
  end

  def unsuppress?
    staff?
  end
end
