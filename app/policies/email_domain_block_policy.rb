# frozen_string_literal: true

class EmailDomainBlockPolicy < ApplicationPolicy
  def index?
    role.can?(:manage_blocks)
  end

  def show?
    role.can?(:manage_blocks)
  end

  def create?
    role.can?(:manage_blocks)
  end

  def destroy?
    role.can?(:manage_blocks)
  end
end
