# frozen_string_literal: true

class AccountPolicy < ApplicationPolicy
  def index?
    staff?
  end

  def show?
    staff?
  end

  def suspend?
    staff?
  end

  def unsuspend?
    staff?
  end

  def silence?
    staff?
  end

  def unsilence?
    staff?
  end

  def redownload?
    admin?
  end

  def subscribe?
    admin?
  end

  def unsubscribe?
    admin?
  end

  def memorialize?
    admin?
  end
end
