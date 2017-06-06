# frozen_string_literal: true

class RelationshipMap
  attr_reader :account_ids, :account

  def initialize(account_ids, account)
    @account_ids = account_ids
    @account = account
  end

  def following
    @_following ||= relationship_mapping(following_query, :target_account_id)
  end

  def followed_by
    @_followed_by ||= relationship_mapping(followed_by_query, :account_id)
  end

  def blocking
    @_blocking ||= relationship_mapping(blocking_query, :target_account_id)
  end

  def muting
    @_muting ||= relationship_mapping(muting_query, :target_account_id)
  end

  def requested
    @_requested ||= relationship_mapping(requested_query, :target_account_id)
  end

  def domain_blocking
    @_domain_blocking ||= accounts_with_domains.map { |id, domain| [id, blocked_domains.include?(domain)] }.to_h
  end

  private

  def following_query
    account.active_relationships.where(target_account_id: account_ids)
  end

  def followed_by_query
    account.passive_relationships.where(account_id: account_ids)
  end

  def blocking_query
    account.block_relationships.where(target_account_id: account_ids)
  end

  def muting_query
    account.mute_relationships.where(target_account_id: account_ids)
  end

  def requested_query
    account.follow_requests.where(target_account_id: account_ids)
  end

  def accounts_with_domains
    accounts_with_domains_query.map { |a| [a.id, a.domain] }.to_h
  end

  def accounts_with_domains_query
    Account.where(id: account_ids).select(:id, :domain)
  end

  def blocked_domains
    account_domain_blocks_query.pluck(:domain)
  end

  def account_domain_blocks_query
    account.domain_blocks.where(domain: accounts_with_domains.values)
  end

  def relationship_mapping(query, field)
    query.pluck(field).each_with_object({}) { |id, mapping| mapping[id] = true }
  end
end
