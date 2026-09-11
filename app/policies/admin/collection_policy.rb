# frozen_string_literal: true

class Admin::CollectionPolicy < ApplicationPolicy
  def index?
    role.can?(:manage_reports, :manage_users)
  end

  def show?
    role.can?(:manage_reports, :manage_users)
  end

  def destroy?
    role.can?(:manage_reports)
  end

  def update?
    role.can?(:manage_reports)
  end
end
