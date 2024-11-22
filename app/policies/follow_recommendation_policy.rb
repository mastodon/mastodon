# frozen_string_literal: true

class FollowRecommendationPolicy < ApplicationPolicy
  def show?
    role.can?(:manage_taxonomies)
  end

  def suppress?
    role.can?(:manage_taxonomies)
  end

  def unsuppress?
    role.can?(:manage_taxonomies)
  end
end
