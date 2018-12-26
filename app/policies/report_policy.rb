# frozen_string_literal: true

class ReportPolicy < ApplicationPolicy
  def update?
    staff?
  end

  def index?
    staff?
  end

  def show?
    staff?
  end
end
