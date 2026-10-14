# frozen_string_literal: true

module Admin::ModerationSubscriptionsHelper
  def moderation_subscription_action_label(type)
    safe_join(
      [
        t("admin.moderation_subscriptions.list_actions.#{type}"),
        content_tag(:span, t("admin.moderation_subscriptions.list_actions_hint.#{type}"), class: 'hint'),
      ]
    )
  end

  def moderation_subscription_apply_conditions_label(type)
    safe_join(
      [
        t("admin.moderation_subscriptions.apply_conditions.#{type}"),
        content_tag(:span, t("admin.moderation_subscriptions.apply_conditions_hint.#{type}"), class: 'hint'),
      ]
    )
  end

  def moderation_subscription_badge(subscription)
    action = subscription.list_action || 'default'
    return unless %w(accept reject default).include?(action)

    content_tag(
      :span,
      I18n.t("admin.moderation_subscriptions.list_actions_short.#{action}"),
      class: ['information-badge', action]
    )
  end
end
