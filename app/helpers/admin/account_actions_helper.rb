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

  def label_and_categories_collection(warning_presets)
    warning_presets.map { |p| [[p.title.presence, truncate(p.text)].compact.join(' - '), p.id, { data: { type: p.action_category } }] }
  end
end
