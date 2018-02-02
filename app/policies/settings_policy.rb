# frozen_string_literal: true

class SettingsPolicy < ApplicationPolicy
  def update?
    admin?
  end

  def show?
    admin?
  end
end
