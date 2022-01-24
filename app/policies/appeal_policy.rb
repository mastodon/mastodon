# frozen_string_literal: true

class AppealPolicy < ApplicationPolicy
  def approve?
    !record.strike.appealed? && staff?
  end
end
