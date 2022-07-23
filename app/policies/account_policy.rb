# frozen_string_literal: true

class AccountPolicy < ApplicationPolicy
  def index?
    role.can?(:manage_users)
  end

  def show?
    role.can?(:manage_users)
  end

  def warn?
    role.can?(:manage_users, :manage_reports) && role.overrides?(record.user_role)
  end

  def suspend?
    role.can?(:manage_users, :manage_reports) && role.overrides?(record.user_role) && !record.instance_actor?
  end

  def destroy?
    record.suspended_temporarily? && role.can?(:delete_user_data)
  end

  def unsuspend?
    role.can?(:manage_users) && record.suspension_origin_local?
  end

  def sensitive?
    role.can?(:manage_users, :manage_reports) && role.overrides?(record.user_role)
  end

  def unsensitive?
    role.can?(:manage_users)
  end

  def silence?
    role.can?(:manage_users, :manage_reports) && role.overrides?(record.user_role)
  end

  def unsilence?
    role.can?(:manage_users)
  end

  def redownload?
    role.can?(:manage_federation)
  end

  def remove_avatar?
    role.can?(:manage_users, :manage_reports) && role.overrides?(record.user_role)
  end

  def remove_header?
    role.can?(:manage_users, :manage_reports) && role.overrides?(record.user_role)
  end

  def memorialize?
    role.can?(:delete_user_data) && role.overrides?(record.user_role) && !record.instance_actor?
  end

  def unblock_email?
    role.can?(:manage_users)
  end

  def review?
    role.can?(:manage_taxonomies)
  end
end
