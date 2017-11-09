# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def reset_password?
    staff?
  end

  def disable_2fa?
    admin?
  end

  def confirm?
    staff?
  end

  def enable?
    admin?
  end

  def disable?
    admin?
  end
end
