# frozen_string_literal: true

module Admin::AccountActionsHelper
  def account_action_type_label(type)
    safe_join(
      [
        I18n.t("simple_form.labels.admin_account_action.types.#{type}"),
        content_tag(:span, I18n.t("simple_form.hints.admin_account_action.types.#{type}"), class: 'hint'),
      ]
    )
  end
end
