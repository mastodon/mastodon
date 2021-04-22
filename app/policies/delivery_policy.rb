# frozen_string_literal: true

class DeliveryPolicy < ApplicationPolicy
  def clear_delivery_errors?
    admin?
  end

  def restart_delivery?
    admin?
  end

  def stop_delivery?
    admin?
  end
end
