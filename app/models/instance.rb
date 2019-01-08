# frozen_string_literal: true

class Instance
  include ActiveModel::Model

  attr_accessor :domain, :accounts_count, :domain_block

  def initialize(resource)
    @domain         = resource.domain
    @accounts_count = resource.accounts_count
    @domain_block   = resource.is_a?(DomainBlock) ? resource : DomainBlock.find_by(domain: domain)
  end

  def cached_sample_accounts
    Rails.cache.fetch("#{cache_key}/sample_accounts", expires_in: 12.hours) { Account.where(domain: domain).searchable.joins(:account_stat).popular.limit(3) }
  end

  def to_param
    domain
  end

  def cache_key
    domain
  end
end
