# frozen_string_literal: true

class Admin::ServerCheckPolicy < ApplicationPolicy
  def index?
    role.can?(:view_dashboard)
  end

  def ignore?
    record.authorized?(current_user)
  end

  def restore?
    record.authorized?(current_user)
  end
end
