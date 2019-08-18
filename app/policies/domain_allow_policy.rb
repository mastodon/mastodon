# frozen_string_literal: true

class DomainAllowPolicy < ApplicationPolicy
  def create?
    admin?
  end

  def destroy?
    admin?
  end
end
