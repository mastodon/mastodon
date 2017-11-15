# frozen_string_literal: true

class InstancePolicy < ApplicationPolicy
  def index?
    admin?
  end

  def resubscribe?
    admin?
  end
end
