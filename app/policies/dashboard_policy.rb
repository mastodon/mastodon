class DashboardPolicy < ApplicationPolicy
  def index?
    role.can?(:view_dashboard)
  end
end
