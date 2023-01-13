# frozen_string_literal: true

class RulePolicy < ApplicationPolicy
  def index?
    role.can?(:manage_rules)
  end

  def create?
    role.can?(:manage_rules)
  end

  def update?
    role.can?(:manage_rules)
  end

  def destroy?
    role.can?(:manage_rules)
  end
end
