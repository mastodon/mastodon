# frozen_string_literal: true

class PreviewCardPolicy < ApplicationPolicy
  def index?
    role.can?(:manage_taxonomies)
  end

  def review?
    role.can?(:manage_taxonomies)
  end
end
