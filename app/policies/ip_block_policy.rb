# frozen_string_literal: true

class IpBlockPolicy < ApplicationPolicy
  def index?
    role.can?(:manage_blocks)
  end

  def show?
    role.can?(:manage_blocks)
  end

  def create?
    role.can?(:manage_blocks)
  end

  def update?
    role.can?(:manage_blocks)
  end

  def destroy?
    role.can?(:manage_blocks)
  end
end
