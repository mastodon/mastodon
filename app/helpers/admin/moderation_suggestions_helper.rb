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
end
