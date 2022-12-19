class RelayPolicy < ApplicationPolicy
  def update?
    role.can?(:manage_federation)
  end
end
