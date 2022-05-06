# frozen_string_literal: true

class PreviewCardProviderPolicy < ApplicationPolicy
  def index?
    staff?
  end

  def review?
    staff?
  end
end
