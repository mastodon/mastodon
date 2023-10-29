# frozen_string_literal: true

class WebhookPolicy < ApplicationPolicy
  def index?
    role.can?(:manage_webhooks)
  end

  def create?
    role.can?(:manage_webhooks)
  end

  def show?
    role.can?(:manage_webhooks)
  end

  def update?
    role.can?(:manage_webhooks) && record.required_permissions.all? { |permission| role.can?(permission) }
  end

  def enable?
    role.can?(:manage_webhooks)
  end

  def disable?
    role.can?(:manage_webhooks)
  end

  def rotate_secret?
    role.can?(:manage_webhooks)
  end

  def destroy?
    role.can?(:manage_webhooks) && record.required_permissions.all? { |permission| role.can?(permission) }
  end
end
