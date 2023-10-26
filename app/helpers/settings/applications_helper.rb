# frozen_string_literal: true

module Settings::ApplicationsHelper
  def doorkeeper_scope_label(scope)
    safe_join(
      [
        content_tag(:samp, scope, class: class_for_scope(scope)),
        content_tag(:span, t("doorkeeper.scopes.#{scope}"), class: 'hint'),
      ]
    )
  end
end
