# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def reset_password?
    role.can?(:manage_user_access) && role.overrides?(record.role)
  end

  def change_email?
    role.can?(:manage_user_access) && role.overrides?(record.role)
  end

  def disable_2fa?
    role.can?(:manage_user_access) && role.overrides?(record.role)
  end

  def change_role?
    role.can?(:manage_roles) && role.overrides?(record.role)
  end

  def confirm?
    role.can?(:manage_user_access) && !record.confirmed?
  end

  def enable?
    role.can?(:manage_users)
  end

  def approve?
    role.can?(:manage_users) && !record.approved?
  end

  def reject?
    role.can?(:manage_users) && !record.approved?
  end

  def disable?
    role.can?(:manage_users) && role.overrides?(record.role)
  end
end
