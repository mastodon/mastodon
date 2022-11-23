# frozen_string_literal: true

class AppealPolicy < ApplicationPolicy
  def index?
    role.can?(:manage_appeals)
  end

  def approve?
    record.pending? && role.can?(:manage_appeals)
  end

  def reject?
    record.pending? && role.can?(:manage_appeals)
  end
end
