# frozen_string_literal: true

class Instance
  include ActiveModel::Model

  attr_accessor :domain, :accounts_count, :domain_block

  def initialize(resource)
    @domain         = resource.domain
    @accounts_count = resource.is_a?(DomainBlock) ? nil : resource.accounts_count
    @domain_block   = resource.is_a?(DomainBlock) ? resource : DomainBlock.rule_for(domain)
  end

  def countable?
    @accounts_count.present?
  end

  def to_param
    domain
  end

  def cache_key
    domain
  end
end
