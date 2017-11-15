# frozen_string_literal: true

class SubscriptionPolicy < ApplicationPolicy
  def index?
    admin?
  end
end
