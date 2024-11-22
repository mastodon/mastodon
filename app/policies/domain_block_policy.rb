# frozen_string_literal: true

class DomainBlockPolicy < ApplicationPolicy
  def index?
    role.can?(:manage_federation)
  end

  def show?
    role.can?(:manage_federation)
  end

  def create?
    role.can?(:manage_federation)
  end

  def update?
    role.can?(:manage_federation)
  end

  def destroy?
    role.can?(:manage_federation)
  end
end
