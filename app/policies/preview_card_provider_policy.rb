# frozen_string_literal: true

class PreviewCardProviderPolicy < ApplicationPolicy
  def index?
    role.can?(:manage_taxonomies)
  end

  def review?
    role.can?(:manage_taxonomies)
  end
end
