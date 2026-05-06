# frozen_string_literal: true

class Admin::StatusPolicy < ApplicationPolicy
  def index?
    role.can?(:manage_reports, :manage_users)
  end

  def show?
    role.can?(:manage_reports, :manage_users) && eligible_to_show?
  end

  def destroy?
    role.can?(:manage_reports)
  end

  def update?
    role.can?(:manage_reports)
  end

  def review?
    role.can?(:manage_taxonomies)
  end

  private

  def eligible_to_show?
    record.distributable? || record.reported? || viewable_through_normal_policy?
  end

  def viewable_through_normal_policy?
    StatusPolicy.new(current_account, record).show?
  end
end
