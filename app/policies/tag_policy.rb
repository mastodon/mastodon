# frozen_string_literal: true

class TagPolicy < ApplicationPolicy
  def index?
    staff?
  end

  def hide?
    staff?
  end

  def unhide?
    staff?
  end
end
