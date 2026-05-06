# frozen_string_literal: true

class CollectionItemPolicy < ApplicationPolicy
  def revoke?
    featured_account.present? && current_account == featured_account
  end

  private

  def featured_account
    record.account
  end
end
