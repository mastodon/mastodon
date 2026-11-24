# frozen_string_literal: true

module Admin::RelaysHelper
  def relays_direction_label(direction)
    safe_join(
      [
        I18n.t("simple_form.labels.relay.directions.#{direction}"),
        content_tag(:span, I18n.t("simple_form.hints.relay.directions.#{direction}"), class: 'hint'),
      ]
    )
  end

  def relay_badge_class(relay)
    if relay.accepted?
      'accept'
    elsif relay.pending?
      nil
    else
      'reject'
    end
  end
end
