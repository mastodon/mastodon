# frozen_string_literal: true

class AppealPolicy < ApplicationPolicy
  def index?
    staff?
  end

  def approve?
    record.pending? && staff?
  end

  alias reject? approve?
end
