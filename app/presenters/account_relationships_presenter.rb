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
    uncached_domains = []
    blocks_by_domain = target_domains.index_with(false)

    # Fetch from cache
    unless target_domains.empty?
      cache_keys = target_domains.map { |domain| "exclude_domains:#{@current_account_id}:#{domain}" }
      target_domains.zip(Rails.cache.read_multi(cache_keys)).each do |domain, blocking|
        if blocking.nil?
          uncached_domains << domain
        else
          blocks_by_domain[domain] = blocking
        end
      end
    end

    # Read uncached values from database
    AccountDomainBlock.where(account_id: @current_account_id, domain: uncached_domains).pluck(:domain).each do |domain|
      blocks_by_domain[domain] = true
    end

    # Write database reads to cache
    uncached_domains.each do |domain|
      Rails.cache.write("exclude_domains:#{@current_account_id}:#{domain}", blocks_by_domain[domain], expires_in: 1.day)
    end

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

    @uncached_account_ids = []

    return @cached if @account_ids.empty?

    cache_ids = @account_ids.map { |account_id| "relationship:#{@current_account_id}:#{account_id}" }
    @account_ids.zip(Rails.cache.read_multi(cache_ids)).each do |account_id, maps_for_account|
      if maps_for_account.is_a?(Hash)
        @cached.deep_merge!(maps_for_account)
      else
        @uncached_account_ids << account_id
      end
    end

    @cached
  end

  def cache_uncached!
    @uncached_account_ids.each do |account_id|
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

      Rails.cache.write("relationship:#{@current_account_id}:#{account_id}", maps_for_account, expires_in: 1.day)
    end
  end
end
