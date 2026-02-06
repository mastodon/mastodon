# frozen_string_literal: true

class AccountRelationshipsPresenter
  attr_reader :following, :followed_by, :blocking, :blocked_by,
              :muting, :requested, :requested_by, :domain_blocking,
              :endorsed, :account_note

  def initialize(accounts, current_account_id, **options)
    @accounts = accounts.to_a
    @account_ids        = @accounts.pluck(:id)
    @current_account_id = current_account_id

    @following       = cached[:following].merge(Account.following_map(@uncached_account_ids, @current_account_id))
    @followed_by     = cached[:followed_by].merge(Account.followed_by_map(@uncached_account_ids, @current_account_id))
    @blocking        = cached[:blocking].merge(Account.blocking_map(@uncached_account_ids, @current_account_id))
    @blocked_by      = cached[:blocked_by].merge(Account.blocked_by_map(@uncached_account_ids, @current_account_id))
    @muting          = cached[:muting].merge(Account.muting_map(@uncached_account_ids, @current_account_id))
    @requested       = cached[:requested].merge(Account.requested_map(@uncached_account_ids, @current_account_id))
    @requested_by    = cached[:requested_by].merge(Account.requested_by_map(@uncached_account_ids, @current_account_id))
    @endorsed        = cached[:endorsed].merge(Account.endorsed_map(@uncached_account_ids, @current_account_id))
    @account_note    = cached[:account_note].merge(Account.account_note_map(@uncached_account_ids, @current_account_id))

    @domain_blocking = domain_blocking_map

    cache_uncached!

    @following.merge!(options[:following_map] || {})
    @followed_by.merge!(options[:followed_by_map] || {})
    @blocking.merge!(options[:blocking_map] || {})
    @blocked_by.merge!(options[:blocked_by_map] || {})
    @muting.merge!(options[:muting_map] || {})
    @requested.merge!(options[:requested_map] || {})
    @requested_by.merge!(options[:requested_by_map] || {})
    @domain_blocking.merge!(options[:domain_blocking_map] || {})
    @endorsed.merge!(options[:endorsed_map] || {})
    @account_note.merge!(options[:account_note_map] || {})
  end

  private

  def domain_blocking_map
    target_domains = @accounts.pluck(:domain).compact.uniq
    blocks_by_domain = {}

    # Fetch from cache
    cache_keys = target_domains.map { |domain| domain_cache_key(domain) }
    Rails.cache.read_multi(*cache_keys).each do |key, blocking|
      blocks_by_domain[key.last] = blocking
    end

    uncached_domains = target_domains - blocks_by_domain.keys

    # Read uncached values from database
    AccountDomainBlock.where(account_id: @current_account_id, domain: uncached_domains).pluck(:domain).each do |domain|
      blocks_by_domain[domain] = true
    end

    # Write database reads to cache
    to_cache = uncached_domains.to_h { |domain| [domain_cache_key(domain), blocks_by_domain[domain]] }
    Rails.cache.write_multi(to_cache, expires_in: 1.day)

    # Return formatted value
    @accounts.each_with_object({}) { |account, h| h[account.id] = blocks_by_domain[account.domain] }
  end

  def cached
    return @cached if defined?(@cached)

    @cached = {
      following: {},
      followed_by: {},
      blocking: {},
      blocked_by: {},
      muting: {},
      requested: {},
      requested_by: {},
      endorsed: {},
      account_note: {},
    }

    @uncached_account_ids = @account_ids.uniq

    cache_ids = @account_ids.map { |account_id| relationship_cache_key(account_id) }
    Rails.cache.read_multi(*cache_ids).each do |key, maps_for_account|
      @cached.deep_merge!(maps_for_account)
      @uncached_account_ids.delete(key.last)
    end

    @cached
  end

  def cache_uncached!
    to_cache = @uncached_account_ids.to_h do |account_id|
      maps_for_account = {
        following: { account_id => following[account_id] },
        followed_by: { account_id => followed_by[account_id] },
        blocking: { account_id => blocking[account_id] },
        blocked_by: { account_id => blocked_by[account_id] },
        muting: { account_id => muting[account_id] },
        requested: { account_id => requested[account_id] },
        requested_by: { account_id => requested_by[account_id] },
        endorsed: { account_id => endorsed[account_id] },
        account_note: { account_id => account_note[account_id] },
      }

      [relationship_cache_key(account_id), maps_for_account]
    end

    Rails.cache.write_multi(to_cache, expires_in: 1.day)
  end

  def domain_cache_key(domain)
    ['exclude_domains', @current_account_id, domain]
  end

  def relationship_cache_key(account_id)
    ['relationships', @current_account_id, account_id]
  end
end
