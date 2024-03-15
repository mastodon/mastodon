# frozen_string_literal: true

module FiltersHelper
  def filter_action_label(action)
    safe_join(
      [
        t("simple_form.labels.filters.actions.#{action}"),
        content_tag(:span, t("simple_form.hints.filters.actions.#{action}"), class: 'hint'),
      ]
    )
  end
end
