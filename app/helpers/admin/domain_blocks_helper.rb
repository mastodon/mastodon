# frozen_string_literal: true

module Admin::DomainBlocksHelper
  CONNECTOR = ' · '

  def domain_block_policies(domain_block)
    domain_block
      .policies
      .map { |policy| t("admin.instances.content_policies.policies.#{policy}") }
      .join(CONNECTOR)
  end
end
