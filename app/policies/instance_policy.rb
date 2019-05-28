# frozen_string_literal: true

class InstancePolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin?
  end
end
