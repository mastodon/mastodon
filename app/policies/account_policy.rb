# frozen_string_literal: true

class AccountPolicy < ApplicationPolicy
  def index?
    staff?
  end

  def show?
    staff?
  end

  def suspend?
    staff? && !record.user&.staff?
  end

  def unsuspend?
    staff?
  end

  def silence?
    staff? && !record.user&.staff?
  end

  def unsilence?
    staff?
  end

  def redownload?
    admin?
  end

  def remove_avatar?
    staff?
  end

  def subscribe?
    admin?
  end

  def unsubscribe?
    admin?
  end

  def memorialize?
    admin? && !record.user&.admin?
  end
end
