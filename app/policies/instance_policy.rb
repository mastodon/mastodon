# frozen_string_literal: true

class InstancePolicy < ApplicationPolicy
  def index?
    role.can?(:manage_federation)
  end

  def show?
    role.can?(:manage_federation)
  end

  def destroy?
    role.can?(:manage_federation)
  end
end
