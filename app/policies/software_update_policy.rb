# frozen_string_literal: true

class SoftwareUpdatePolicy < ApplicationPolicy
  def index?
    role.can?(:view_devops)
  end
end
