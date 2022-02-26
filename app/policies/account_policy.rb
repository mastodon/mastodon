# frozen_string_literal: true

class AccountPolicy < ApplicationPolicy
  def index?
    staff?
  end

  def show?
    staff?
  end

  def warn?
    staff? && !record.user&.staff?
  end

  def suspend?
    staff? && !record.user&.staff? && !record.instance_actor?
  end

  def destroy?
    record.suspended_temporarily? && admin?
  end

  def unsuspend?
    staff? && record.suspension_origin_local?
  end

  def sensitive?
    staff? && !record.user&.staff?
  end

  def unsensitive?
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

  def remove_header?
    staff?
  end

  def subscribe?
    admin?
  end

  def unsubscribe?
    admin?
  end

  def memorialize?
    admin? && !record.user&.admin? && !record.instance_actor?
  end

  def unblock_email?
    staff?
  end

  def review?
    staff?
  end
end
