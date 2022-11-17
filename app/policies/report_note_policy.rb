# frozen_string_literal: true

class ReportNotePolicy < ApplicationPolicy
  def create?
    role.can?(:manage_reports)
  end

  def destroy?
    owner? || (role.can?(:manage_reports) && role.overrides?(record.account.user_role))
  end

  private

  def owner?
    record.account_id == current_account&.id
  end
end
