# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def reset_password?
    staff? && !record.staff?
  end

  def disable_2fa?
    admin? && !record.staff?
  end

  def confirm?
    staff? && !record.confirmed?
  end

  def enable?
    admin?
  end

  def disable?
    admin? && !record.admin?
  end

  def promote?
    admin? && promoteable?
  end

  def demote?
    admin? && !record.admin? && demoteable?
  end

  private

  def promoteable?
    !record.staff? || !record.admin?
  end

  def demoteable?
    record.staff?
  end
end
