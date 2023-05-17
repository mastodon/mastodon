# frozen_string_literal: true

class Emergency::RulePolicy < ApplicationPolicy
  def create?
    false # TODO
  end

  def index?
    role.can?(:manage_reports, :view_audit_log, :manage_users, :manage_invites, :manage_taxonomies, :manage_federation, :manage_blocks)
  end

  def deactivate?
    role.can?(:manage_reports, :view_audit_log, :manage_users, :manage_invites, :manage_taxonomies, :manage_federation, :manage_blocks)
  end
end
