# frozen_string_literal: true

class AuditLogPolicy < ApplicationPolicy
  def index?
    role.can?(:view_audit_log)
  end
end
