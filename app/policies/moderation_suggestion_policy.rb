# frozen_string_literal: true

class ModerationSuggestionPolicy < ApplicationPolicy
  def index?
    role.can?(:manage_federation)
  end

  def show?
    role.can?(:manage_federation)
  end

  def dismiss?
    role.can?(:manage_federation)
  end

  def apply?
    role.can?(:manage_federation)
  end
end
