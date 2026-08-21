# frozen_string_literal: true

module Admin::ContentPoliciesHelper
  def policy_list(domain_block)
    domain_block
      .policies
      .map { |policy| I18n.t("admin.instances.content_policies.policies.#{policy}") }
      .join(' · ')
  end

  def moderation_subscription_policy_list(moderation_subscription)
    policies = []

    if moderation_subscription.apply_automatically?
      policies << (moderation_subscription.preserve_relationships? ? :apply_advisories_safely : :apply_advisories)
    end

    policies << :apply_retractions if moderation_subscription.retract_automatically?

    policies
      .map { |policy| I18n.t("admin.moderation_subscriptions.policies.#{policy}") }
      .join(' · ')
  end
end
