# frozen_string_literal: true

class UserRolePolicy < ApplicationPolicy
  def index?
    role.can?(:manage_roles)
  end

  def create?
    role.can?(:manage_roles)
  end

  def update?
    role.can?(:manage_roles) && (role.overrides?(record) || role.id == record.id)
  end

  def destroy?
    !record.everyone? && role.can?(:manage_roles) && role.overrides?(record) && role.id != record.id
  end
end
