# frozen_string_literal: true

class InlineRablScope
  include RoutingHelper

  def initialize(account)
    @account = account
  end

  def current_user
    @account.try(:user)
  end

  def current_account
    @account
  end
end
