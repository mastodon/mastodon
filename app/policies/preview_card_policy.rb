# frozen_string_literal: true

class PreviewCardPolicy < ApplicationPolicy
  def index?
    staff?
  end

  def update?
    staff?
  end
end
