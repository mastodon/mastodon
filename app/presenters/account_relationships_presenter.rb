# frozen_string_literal: true

class AccountRelationshipsPresenter
  attr_reader :following, :followed_by, :blocking, :blocked_by,
              :muting, :requested, :domain_blocking,
              :endorsed, :account_note

  def initialize(account_ids, current_account_id, **options)
    @account_ids        = account_ids.map { |a| a.is_a?(Account) ? a.id : a.to_i }
    @current_account_id = current_account_id

    @following       = cached[:following].merge(Account.following_map(@uncached_account_ids, @current_account_id))
    @followed_by     = cached[:followed_by].merge(Account.followed_by_map(@uncached_account_ids, @current_account_id))
    @blocking        = cached[:blocking].merge(Account.blocking_map(@uncached_account_ids, @current_account_id))
    @blocked_by      = cached[:blocked_by].merge(Account.blocked_by_map(@uncached_account_ids, @current_account_id))
    @muting          = cached[:muting].merge(Account.muting_map(@uncached_account_ids, @current_account_id))
    @requested       = cached[:requested].merge(Account.requested_map(@uncached_account_ids, @current_account_id))
    @domain_blocking = cached[:domain_blocking].merge(Account.domain_blocking_map(@uncached_account_ids, @current_account_id))
    @endorsed        = cached[:endorsed].merge(Account.endorsed_map(@uncached_account_ids, @current_account_id))
    @account_note    = cached[:account_note].merge(Account.account_note_map(@uncached_account_ids, @current_account_id))

    cache_uncached!

    @following.merge!(options[:following_map] || {})
    @followed_by.merge!(options[:followed_by_map] || {})
    @blocking.merge!(options[:blocking_map] || {})
    @blocked_by.merge!(options[:blocked_by_map] || {})
    @muting.merge!(options[:muting_map] || {})
    @requested.merge!(options[:requested_map] || {})
    @domain_blocking.merge!(options[:domain_blocking_map] || {})
    @endorsed.merge!(options[:endorsed_map] || {})
    @account_note.merge!(options[:account_note_map] || {})
  end

  private

  def cached
    return @cached if defined?(@cached)

    @cached = {
      following: {},
      followed_by: {},
      blocking: {},
      blocked_by: {},
      muting: {},
      requested: {},
      domain_blocking: {},
      endorsed: {},
      account_note: {},
    }

    @uncached_account_ids = []

    @account_ids.each do |account_id|
      maps_for_account = Rails.cache.read("relationship:#{@current_account_id}:#{account_id}")

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
        following:       { account_id => following[account_id] },
        followed_by:     { account_id => followed_by[account_id] },
        blocking:        { account_id => blocking[account_id] },
        blocked_by:      { account_id => blocked_by[account_id] },
        muting:          { account_id => muting[account_id] },
        requested:       { account_id => requested[account_id] },
        domain_blocking: { account_id => domain_blocking[account_id] },
        endorsed:        { account_id => endorsed[account_id] },
        account_note:    { account_id => account_note[account_id] },
      }

      Rails.cache.write("relationship:#{@current_account_id}:#{account_id}", maps_for_account, expires_in: 1.day)
    end
  end
end
