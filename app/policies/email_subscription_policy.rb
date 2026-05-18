# frozen_string_literal: true

class EmailSubscriptionPolicy < ApplicationPolicy
  def index?
    role.can?(:manage_settings)
  end

  alias enable? index?

  alias disable? index?

  alias purge? index?
end
