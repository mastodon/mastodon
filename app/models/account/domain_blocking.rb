# frozen_string_literal: true

module Account::DomainBlocking
  extend ActiveSupport::Concern

  included do
    has_many :domain_blocks, class_name: 'AccountDomainBlock', dependent: :destroy
  end

  def block_domain!(domain)
    domain_blocks.find_or_create_by!(domain:)
  end

  def unblock_domain!(domain)
    domain_blocks
      .find_by(domain: TagManager.instance.normalize_domain(domain))
      &.destroy
  end

  def domain_blocking?(domain)
    preloaded_relation(:domain_blocking_by_domain, domain) do
      domain_blocks.exists?(domain:)
    end
  end
end
