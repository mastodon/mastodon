# frozen_string_literal: true

module Admin::AccountActionsHelper
  ACTION_TO_CATEGORY = {
    'warning' => 'none',
    'freeze' => 'disable',
    'limit' => 'silence',
    'suspend' => 'suspend',
    'sensitive' => 'sensitive',
  }.freeze

  def account_action_type_label(type)
    safe_join(
      [
        I18n.t("simple_form.labels.admin_account_action.types.#{type}"),
        content_tag(:span, I18n.t("simple_form.hints.admin_account_action.types.#{type}"), class: 'hint'),
      ]
    )
  end

  def filtered_collection(presets, type)
    presets.filter { |i| i.action_category == ACTION_TO_CATEGORY[type] || nil }
  end
end
