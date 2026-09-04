# frozen_string_literal: true

module Admin::ModerationSuggestionsHelper
  ACTION_ICON_NAMES = {
    accept: 'check',
    reject: 'block',
    limit: 'do_not_disturb_on',
    retract: 'backspace',
  }.freeze

  def advisory_action_icon(action)
    material_symbol(ACTION_ICON_NAMES.fetch(action.to_sym))
  end

  def advisory_action_link(action, suggestion)
    link_to(
      safe_join([advisory_action_icon(action), t("admin.moderation_suggestions.apply_#{action}")]),
      suggestion ? apply_admin_moderation_suggestion_path(suggestion) : nil,
      { class: ['button', 'button-secondary', disabled: !suggestion], method: :post }
    )
  end
end
