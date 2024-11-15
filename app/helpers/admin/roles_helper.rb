# frozen_string_literal: true

module Admin
  module RolesHelper
    def privilege_label(privilege)
      safe_join(
        [
          t("admin.roles.privileges.#{privilege}"),
          content_tag(:span, t("admin.roles.privileges.#{privilege}_description"), class: 'hint'),
        ]
      )
    end

    def role_priveleges(role)
      role
        .permissions_as_keys
        .map { |privilege| t("admin.roles.privileges.#{privilege}") }
        .join(', ')
    end

    def disable_permissions?(permissions)
      permissions.filter { |privilege| role_flag_value(privilege).zero? }
    end

    private

    def role_flag_value(privilege)
      UserRole::FLAGS[privilege] & current_user.role.computed_permissions
    end
  end
end
