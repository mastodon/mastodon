# frozen_string_literal: true

class DeliveryPolicy < ApplicationPolicy
  def clear_delivery_errors?
    role.can?(:manage_federation)
  end

  def restart_delivery?
    role.can?(:manage_federation)
  end

  def stop_delivery?
    role.can?(:manage_federation)
  end
end
