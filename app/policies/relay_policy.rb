# frozen_string_literal: true

class RelayPolicy < ApplicationPolicy
  def update?
    admin?
  end
end
