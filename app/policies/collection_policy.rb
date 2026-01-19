# frozen_string_literal: true

class CollectionPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    current_account.nil? || (!owner_blocking? && !owner_blocking_domain?)
  end

  def create?
    user_signed_in?
  end

  def update?
    owner?
  end

  def destroy?
    owner?
  end

  private

  def owner?
    current_account == owner
  end

  def owner_blocking_domain?
    return false if current_account.nil? || current_account.domain.nil?

    owner.domain_blocking?(current_account.domain)
  end

  def owner_blocking?
    return false if current_account.nil?

    current_account.blocked_by?(owner)
  end

  def owner
    record.account
  end
end
