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
  end
end
