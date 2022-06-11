# frozen_string_literal: true

class DomainAllowPolicy < ApplicationPolicy
  def create?
    role.can?(:manage_federation)
  end

  def destroy?
    role.can?(:manage_federation)
  end
end
