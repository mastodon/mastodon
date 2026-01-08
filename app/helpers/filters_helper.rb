# frozen_string_literal: true

module FiltersHelper
  KEYWORDS_LIMIT = 5

  def filter_action_label(action)
    safe_join(
      [
        t("simple_form.labels.filters.actions.#{action}"),
        content_tag(:span, t("simple_form.hints.filters.actions.#{action}"), class: 'hint'),
      ]
    )
  end

  def filter_keywords(filter)
    filter.keywords.map(&:keyword).take(KEYWORDS_LIMIT).tap do |list|
      list << '…' if filter.keywords.size > KEYWORDS_LIMIT
    end.join(', ')
  end
end
