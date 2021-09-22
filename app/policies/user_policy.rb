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

  def disable_sign_in_token_auth?
    staff?
  end

  def enable_sign_in_token_auth?
    staff?
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
    admin? && promoteable?
  end

  def demote?
    admin? && !record.admin? && demoteable?
  end

  private

  def promoteable?
    record.approved? && (!record.staff? || !record.admin?)
  end

  def demoteable?
    record.staff?
  end
end
