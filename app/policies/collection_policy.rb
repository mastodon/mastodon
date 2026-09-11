# frozen_string_literal: true

class CollectionPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    current_account.nil? || !owner.blocking_or_domain_blocking?(current_account)
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

  def owner
    record.account
  end
end
