# frozen_string_literal: true

class TermsOfServicePolicy < ApplicationPolicy
  def index?
    role.can?(:manage_settings)
  end

  def create?
    role.can?(:manage_settings)
  end

  def distribute?
    record.published? && !record.notification_sent? && role.can?(:manage_settings)
  end

  def update?
    !record.published? && role.can?(:manage_settings)
  end

  def destroy?
    !record.published? && role.can?(:manage_settings)
  end
end
