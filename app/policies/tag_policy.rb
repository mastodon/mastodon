# frozen_string_literal: true

class TagPolicy < ApplicationPolicy
  def index?
    role.can?(:manage_taxonomies)
  end

  def show?
    role.can?(:manage_taxonomies)
  end

  def update?
    role.can?(:manage_taxonomies)
  end

  def review?
    role.can?(:manage_taxonomies)
  end
end
