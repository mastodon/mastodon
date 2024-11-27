# frozen_string_literal: true

class ListPolicy < ApplicationPolicy
  def show?
    record.public_list? || owned?
  end

  def update?
    owned?
  end

  def destroy?
    owned?
  end

  private

  def owned?
    user_signed_in? && record.account_id == current_account.id
  end
end
