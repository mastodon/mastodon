# frozen_string_literal: true

class PreviewCardProviderPolicy < ApplicationPolicy
  def index?
    staff?
  end

  def update?
    staff?
  end
end
