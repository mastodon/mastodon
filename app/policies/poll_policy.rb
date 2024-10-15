# frozen_string_literal: true

class PollPolicy < ApplicationPolicy
  def vote?
    viewable_through_normal_policy? && accounts_not_blocking?
  end

  private

  def viewable_through_normal_policy?
    StatusPolicy.new(current_account, record.status).show?
  end

  def accounts_not_blocking?
    !current_account.blocking?(record.account) && !record.account.blocking?(current_account)
  end
end
