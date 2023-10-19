# frozen_string_literal: true

module Admin
  module DisputesHelper
    def strike_action_label(appeal)
      t(key_for_action(appeal),
        scope: 'admin.strikes.actions',
        name: content_tag(:span, appeal.strike.account.username, class: 'username'),
        target: content_tag(:span, appeal.account.username, class: 'target'))
        .html_safe
    end

    private

    def key_for_action(appeal)
      AccountWarning.actions.slice(appeal.strike.action).keys.first
    end
  end
end
