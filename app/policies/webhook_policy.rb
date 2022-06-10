# frozen_string_literal: true

class WebhookPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def create?
    admin?
  end

  def show?
    admin?
  end

  def update?
    admin?
  end

  def enable?
    admin?
  end

  def disable?
    admin?
  end

  def rotate_secret?
    admin?
  end

  def destroy?
    admin?
  end
end
