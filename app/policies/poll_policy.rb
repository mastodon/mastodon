# frozen_string_literal: true

class PollPolicy < ApplicationPolicy
  def vote?
    !current_account.blocking?(record.account) && !record.account.blocking?(current_account)
  end
end
