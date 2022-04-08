# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def reset_password?
    staff? && !record.staff?
  end

  def change_email?
    staff? && !record.staff?
  end

  def disable_2fa?
    admin? && !record.staff?
  end

  def confirm?
    staff? && !record.confirmed?
  end

  def enable?
    staff?
  end

  def approve?
    staff? && !record.approved?
  end

  def reject?
    staff? && !record.approved?
  end

  def disable?
    staff? && !record.admin?
  end

  def promote?
    admin? && promotable?
  end

  def demote?
    admin? && !record.admin? && demoteable?
  end

  private

  def promotable?
    record.approved? && (!record.staff? || !record.admin?)
  end

  def demoteable?
    record.staff?
  end
end
