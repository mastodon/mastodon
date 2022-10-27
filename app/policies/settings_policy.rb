# frozen_string_literal: true

class SettingsPolicy < ApplicationPolicy
  def update?
    role.can?(:manage_settings)
  end

  def show?
    role.can?(:manage_settings)
  end

  def destroy?
    role.can?(:manage_settings)
  end
end
