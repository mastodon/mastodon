# frozen_string_literal: true

module Timeline
  class << self
    def home_from_database(account, limit: nil, max_id: nil, since_id: nil)
      query = Status.where(account: [account] + account.following, visibility: [:public, :unlisted, :private])
                    .order(account_id: :desc)
      query = query.paginate_by_max_id(limit, max_id, since_id) if limit.present?

      query.reject { |status| FeedManager.instance.filter?(:home, status, account.id) }
    end

    def home_from_redis(account, limit: nil, max_id: nil, since_id: nil)
      key        = FeedManager.instance.key(:home, account.id)
      max_id     = '+inf' if max_id.blank?
      since_id   = '-inf' if since_id.blank?
      unhydrated = Redis.current.zrevrangebyscore(key, "(#{max_id}", "(#{since_id}", limit: limit && [0, limit], with_scores: true).map(&:last).map(&:to_i)
      Status.where(id: unhydrated).cache_ids
    end

    def home(account, *rest)
      if Redis.current.exists("account:#{account.id}:regeneration")
        home_from_database(account, *rest)
      else
        home_from_redis(account, *rest)
      end
    end

    def public_from_database(account: nil, local_only: false, limit: nil, max_id: nil, since_id: nil)
      query = generic_public(local_only).without_replies
      query = apply_filters(query, account, local_only)
      query = query.paginate_by_max_id(limit, max_id, since_id) if limit.present?
      query
    end

    alias public public_from_database

    def tag_from_database(tag, account: nil, local_only: false, limit: nil, max_id: nil, since_id: nil)
      query = generic_public(local_only).tagged_with(tag)
      query = apply_filters(query, account, local_only)
      query = query.paginate_by_max_id(limit, max_id, since_id) if limit.present?
      query
    end

    alias tag tag_from_database

    private

    def generic_public(local_only = false)
      starting_scope = local_only ? Status.local : Status
      starting_scope.with_public_visibility.without_reblogs
    end

    def apply_filters(query, account, local_only)
      if account.nil?
        filter_default(query)
      else
        filter_for_account(query, account, local_only)
      end
    end

    def filter_for_account(query, account, local_only)
      query = query.not_excluded_by_account(account)
      query = query.not_domain_blocked_by_account(account) unless local_only
      query = query.not_in_filtered_languages(account) if account.filtered_languages.present?
      query.merge(account_silencing_filter(account))
    end

    def filter_default(query)
      query.excluding_silenced_accounts
    end

    def account_silencing_filter(account)
      if account.silenced?
        Status.including_silenced_accounts
      else
        Status.excluding_silenced_accounts
      end
    end
  end
end
