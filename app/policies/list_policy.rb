# frozen_string_literal: true

class ListPolicy < ApplicationPolicy
  def show?
    owner?
  end

  private

  def owner?
    record.account_id == current_account.id
  end
end
