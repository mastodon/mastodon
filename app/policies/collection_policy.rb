# frozen_string_literal: true

class CollectionPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
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
    current_account == record.account
  end
end
