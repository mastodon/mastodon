# frozen_string_literal: true

class REST::CredentialRoleSerializer < REST::RoleSerializer
  attributes :permissions

  def permissions
    object.computed_permissions.to_s
  end
end
