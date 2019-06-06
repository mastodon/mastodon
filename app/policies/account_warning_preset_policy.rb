# frozen_string_literal: true

class AccountWarningPresetPolicy < ApplicationPolicy
  def index?
    staff?
  end

  def create?
    staff?
  end

  def update?
    staff?
  end

  def destroy?
    staff?
  end
end
