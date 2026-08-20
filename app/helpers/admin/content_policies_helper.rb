# frozen_string_literal: true

module Admin::ContentPoliciesHelper
  def policy_list(domain_block)
    domain_block
      .policies
      .map { |policy| I18n.t("admin.instances.content_policies.policies.#{policy}") }
      .join(' · ')
  end
end
