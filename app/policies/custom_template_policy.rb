# frozen_string_literal: true

class CustomTemplatePolicy < ApplicationPolicy
  def index?
    staff?
  end

  def create?
    admin?
  end

  def enable?
    staff?
  end

  def disable?
    staff?
  end

  def destroy?
    admin?
  end
end
