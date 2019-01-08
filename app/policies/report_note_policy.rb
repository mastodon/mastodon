# frozen_string_literal: true

class ReportNotePolicy < ApplicationPolicy
  def create?
    staff?
  end

  def destroy?
    admin? || owner?
  end

  private

  def owner?
    record.account_id == current_account&.id
  end
end
