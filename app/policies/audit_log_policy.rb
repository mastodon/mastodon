class AuditLogPolicy < ApplicationPolicy
  def index?
    role.can?(:view_audit_log)
  end
end
