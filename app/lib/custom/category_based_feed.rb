# frozen_string_literal: true

module Custom::CategoryBasedFeed
  # Override the default method to exclude the possiblity for the private statuses to leak into home feed
  def merge_into_home(from_account, into_account)
    return unless into_account.user&.signed_in_recently?

    timeline_key = key(:home, into_account.id)
    aggregate    = into_account.user&.aggregates_reblogs?
    query        = from_account.statuses.public_visibility.includes(reblog: :account).limit(FeedManager::MAX_ITEMS / 4)

    if redis.zcard(timeline_key) >= FeedManager::MAX_ITEMS / 4
      oldest_home_score = redis.zrange(timeline_key, 0, 0, with_scores: true).first.last.to_i
      query = query.where('id > ?', oldest_home_score)
    end

    statuses = query.to_a
    crutches = build_crutches(into_account.id, statuses)

    statuses.each do |status|
      next if filter_from_home(status, into_account.id, crutches)

      add_to_feed(:home, into_account.id, status, aggregate_reblogs: aggregate)
    end

    trim(:home, into_account.id)
  end

  # Override the default home feed population to add statuses from all the accounts, not just from the followed ones
  def populate_home(account)
    limit        = FeedManager::MAX_ITEMS / 2
    aggregate    = account.user&.aggregates_reblogs?
    timeline_key = key(:home, account.id)
    over_limit = false

    account.statuses.limit(limit).each do |status|
      add_to_feed(:home, account.id, status, aggregate_reblogs: aggregate)
    end

    source_accounts(account.id).find_each do |target_account|
      query = target_account.statuses.public_visibility.includes(reblog: :account).limit(limit)

      over_limit ||= redis.zcard(timeline_key) >= limit
      if over_limit
        oldest_home_score = redis.zrange(timeline_key, 0, 0, with_scores: true).first.last.to_i
        last_status_score = Mastodon::Snowflake.id_at(target_account.last_status_at, with_random: false)

        # If the feed is full and this account has not posted more recently
        # than the last item on the feed, then we can skip the whole account
        # because none of its statuses would stay on the feed anyway
        next if last_status_score < oldest_home_score

        # No need to get older statuses
        query = query.where(id: oldest_home_score...)
      end

      statuses = query.to_a
      next if statuses.empty?

      crutches = build_crutches(account.id, statuses)

      statuses.each do |status|
        next if filter_from_home(status, account.id, crutches)

        add_to_feed(:home, account.id, status, aggregate_reblogs: aggregate)
      end

      trim(:home, account.id)
    end
  end

  # Override the default filtering methods to add category-based filtering
  def filter_from_home(status, receiver_id, crutches, timeline_type = :home)
    previous_filters = super
    return previous_filters if previous_filters

    hidden_categories = crutches[:hidden_categories]
    return nil if hidden_categories.blank?

    author_categories = Array(crutches[:authors_categories][status.account_id])

    author_categories += Array(crutches[:authors_categories][status.reblog.account_id]) if status.reblog? && status.reblog.present?

    # TODO: Remove when all statuses is forced to have categories
    return nil if author_categories.blank?

    author_categories.all? { |cat_id| hidden_categories[cat_id] } ? :filter : nil
  end

  # Override the default crutches build to add category filters used during filtering
  def build_crutches(receiver_id, statuses, list: nil)
    crutches = super

    # Reader's hidden categories (opt-out filters). Indexed for O(1) lookups.
    crutches[:hidden_categories] = AccountCategoryFilter
      .where(account_id: receiver_id)
      .pluck(:category_id)
      .index_with(true)

    # Map involved accounts to their category IDs to avoid per-status queries.
    statuses_account_ids = statuses.flat_map { |s| [s.account_id, s.reblog&.account_id] }.compact
    crutches[:authors_categories] = AccountCategory
      .where(account_id: statuses_account_ids)
      .pluck(:account_id, :category_id)
      .each_with_object({}) do |(account_id, category_id), mapping|
      (mapping[account_id] ||= []) << category_id
    end

    crutches
  end

  private

  def source_accounts(account_id)
    Account.without_suspended.without_silenced.where.not(id: account_id)
      .includes(:account_stat).references(:account_stat).where.not(account_stats: { last_status_at: nil })
      .reorder(nil)
  end
end
