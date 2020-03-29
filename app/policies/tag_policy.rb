# frozen_string_literal: true

class TagPolicy < ApplicationPolicy
  def index?
    staff?
  end

  def show?
    staff?
  end

  def update?
    staff?
  end
end
