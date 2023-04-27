# frozen_string_literal: true

class CanonicalEmailBlockPolicy < ApplicationPolicy
  def index?
    role.can?(:manage_blocks)
  end

  def show?
    role.can?(:manage_blocks)
  end

  def test?
    role.can?(:manage_blocks)
  end

  def create?
    role.can?(:manage_blocks)
  end

  def destroy?
    role.can?(:manage_blocks)
  end
end
