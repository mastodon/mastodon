class ReportPolicy < ApplicationPolicy
  def update?
    role.can?(:manage_reports)
  end

  def index?
    role.can?(:manage_reports)
  end

  def show?
    role.can?(:manage_reports)
  end
end
