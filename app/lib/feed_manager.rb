# frozen_string_literal: true

require 'singleton'

class FeedManager
  include Singleton
  include Redisable

  # Maximum number of items stored in a single feed
  MAX_ITEMS = 800

  # Number of items in the feed since last reblog of status
  # before the new reblog will be inserted. Must be <= MAX_ITEMS
  # or the tracking sets will grow forever
  REBLOG_FALLOFF = 40

  # Execute block for every active account
  # @yield [Account]
  # @return [void]
  def with_active_accounts(&block)
    Account.joins(:user).where('users.current_sign_in_at > ?', User::ACTIVE_DURATION.ago).find_each(&block)
  end

  # Redis key of a feed
  # @param [Symbol] type
  # @param [Integer] id
  # @param [Symbol] subtype
  # @return [String]
  def key(type, id, subtype = nil)
    return "feed:#{type}:#{id}" unless subtype

    "feed:#{type}:#{id}:#{subtype}"
  end

  # Check if the status should not be added to a feed
  # @param [Symbol] timeline_type
  # @param [Status] status
  # @param [Account|List] receiver
  # @return [Boolean]
  def filter?(timeline_type, status, receiver)
    case timeline_type
    when :home
      filter_from_home?(status, receiver.id, build_crutches(receiver.id, [status]), :home)
    when :list
      filter_from_list?(status, receiver) || filter_from_home?(status, receiver.account_id, build_crutches(receiver.account_id, [status]), :list)
    when :mentions
      filter_from_mentions?(status, receiver.id)
    when :tags
      filter_from_tags?(status, receiver.id, build_crutches(receiver.id, [status]))
    else
      false
    end
  end

  # Add a status to a home feed and send a streaming API update
  # @param [Account] account
  # @param [Status] status
  # @param [Boolean] update
  # @return [Boolean]
  def push_to_home(account, status, update: false)
    return false unless add_to_feed(:home, account.id, status, aggregate_reblogs: account.user&.aggregates_reblogs?)

    trim(:home, account.id)
    PushUpdateWorker.perform_async(account.id, status.id, "timeline:#{account.id}", { 'update' => update }) if push_update_required?("timeline:#{account.id}")
    true
  end

  # Remove a status from a home feed and send a streaming API update
  # @param [Account] account
  # @param [Status] status
  # @param [Boolean] update
  # @return [Boolean]
  def unpush_from_home(account, status, update: false)
    return false unless remove_from_feed(:home, account.id, status, aggregate_reblogs: account.user&.aggregates_reblogs?)

    redis.publish("timeline:#{account.id}", Oj.dump(event: :delete, payload: status.id.to_s)) unless update
    true
  end

  # Add a status to a list feed and send a streaming API update
  # @param [List] list
  # @param [Status] status
  # @param [Boolean] update
  # @return [Boolean]
  def push_to_list(list, status, update: false)
    return false if filter_from_list?(status, list) || !add_to_feed(:list, list.id, status, aggregate_reblogs: list.account.user&.aggregates_reblogs?)

    trim(:list, list.id)
    PushUpdateWorker.perform_async(list.account_id, status.id, "timeline:list:#{list.id}", { 'update' => update }) if push_update_required?("timeline:list:#{list.id}")
    true
  end

  # Remove a status from a list feed and send a streaming API update
  # @param [List] list
  # @param [Status] status
  # @param [Boolean] update
  # @return [Boolean]
  def unpush_from_list(list, status, update: false)
    return false unless remove_from_feed(:list, list.id, status, aggregate_reblogs: list.account.user&.aggregates_reblogs?)

    redis.publish("timeline:list:#{list.id}", Oj.dump(event: :delete, payload: status.id.to_s)) unless update
    true
  end

  # Fill a home feed with an account's statuses
  # @param [Account] from_account
  # @param [Account] into_account
  # @return [void]
  def merge_into_home(from_account, into_account)
    timeline_key = key(:home, into_account.id)
    aggregate    = into_account.user&.aggregates_reblogs?
    query        = from_account.statuses.where(visibility: [:public, :unlisted, :private]).includes(:preloadable_poll, :media_attachments, reblog: :account).limit(FeedManager::MAX_ITEMS / 4)

    if redis.zcard(timeline_key) >= FeedManager::MAX_ITEMS / 4
      oldest_home_score = redis.zrange(timeline_key, 0, 0, with_scores: true).first.last.to_i
      query = query.where('id > ?', oldest_home_score)
    end

    statuses = query.to_a
    crutches = build_crutches(into_account.id, statuses)

    statuses.each do |status|
      next if filter_from_home?(status, into_account.id, crutches)

      add_to_feed(:home, into_account.id, status, aggregate_reblogs: aggregate)
    end

    trim(:home, into_account.id)
  end

  # Fill a list feed with an account's statuses
  # @param [Account] from_account
  # @param [List] list
  # @return [void]
  def merge_into_list(from_account, list)
    timeline_key = key(:list, list.id)
    aggregate    = list.account.user&.aggregates_reblogs?
    query        = from_account.statuses.where(visibility: [:public, :unlisted, :private]).includes(:preloadable_poll, :media_attachments, reblog: :account).limit(FeedManager::MAX_ITEMS / 4)

    if redis.zcard(timeline_key) >= FeedManager::MAX_ITEMS / 4
      oldest_home_score = redis.zrange(timeline_key, 0, 0, with_scores: true).first.last.to_i
      query = query.where('id > ?', oldest_home_score)
    end

    statuses = query.to_a
    crutches = build_crutches(list.account_id, statuses)

    statuses.each do |status|
      next if filter_from_home?(status, list.account_id, crutches) || filter_from_list?(status, list)

      add_to_feed(:list, list.id, status, aggregate_reblogs: aggregate)
    end

    trim(:list, list.id)
  end

  # Remove an account's statuses from a home feed
  # @param [Account] from_account
  # @param [Account] into_account
  # @return [void]
  def unmerge_from_home(from_account, into_account)
    timeline_key        = key(:home, into_account.id)
    timeline_status_ids = redis.zrange(timeline_key, 0, -1)

    from_account.statuses.select('id, reblog_of_id').where(id: timeline_status_ids).reorder(nil).find_each do |status|
      remove_from_feed(:home, into_account.id, status, aggregate_reblogs: into_account.user&.aggregates_reblogs?)
    end
  end

  # Remove an account's statuses from a list feed
  # @param [Account] from_account
  # @param [List] list
  # @return [void]
  def unmerge_from_list(from_account, list)
    timeline_key        = key(:list, list.id)
    timeline_status_ids = redis.zrange(timeline_key, 0, -1)

    from_account.statuses.select('id, reblog_of_id').where(id: timeline_status_ids).reorder(nil).find_each do |status|
      remove_from_feed(:list, list.id, status, aggregate_reblogs: list.account.user&.aggregates_reblogs?)
    end
  end

  # Remove a tag's statuses from a home feed
  # @param [Tag] from_tag
  # @param [Account] into_account
  # @return [void]
  def unmerge_tag_from_home(from_tag, into_account)
    timeline_key        = key(:home, into_account.id)
    timeline_status_ids = redis.zrange(timeline_key, 0, -1)

    # This is a bit tricky because we need posts tagged with this hashtag that are not
    # also tagged with another followed hashtag or from a followed user
    scope = from_tag.statuses
                    .where(id: timeline_status_ids)
                    .where.not(account: into_account.following)
                    .tagged_with_none(TagFollow.where(account: into_account).pluck(:tag_id))

    scope.select('id, reblog_of_id').reorder(nil).find_each do |status|
      remove_from_feed(:home, into_account.id, status, aggregate_reblogs: into_account.user&.aggregates_reblogs?)
    end
  end

  # Clear all statuses from or mentioning target_account from a home feed
  # @param [Account] account
  # @param [Account] target_account
  # @return [void]
  def clear_from_home(account, target_account)
    timeline_key        = key(:home, account.id)
    timeline_status_ids = redis.zrange(timeline_key, 0, -1)
    statuses            = Status.where(id: timeline_status_ids).select(:id, :reblog_of_id, :account_id).to_a
    reblogged_ids       = Status.where(id: statuses.filter_map(&:reblog_of_id), account: target_account).pluck(:id)
    with_mentions_ids   = Mention.active.where(status_id: statuses.flat_map { |s| [s.id, s.reblog_of_id] }.compact, account: target_account).pluck(:status_id)

    target_statuses = statuses.select do |status|
      status.account_id == target_account.id || reblogged_ids.include?(status.reblog_of_id) || with_mentions_ids.include?(status.id) || with_mentions_ids.include?(status.reblog_of_id)
    end

    target_statuses.each do |status|
      unpush_from_home(account, status)
    end
  end

  # Clear all statuses from or mentioning target_account from a list feed
  # @param [List] list
  # @param [Account] target_account
  # @return [void]
  def clear_from_list(list, target_account)
    timeline_key        = key(:list, list.id)
    timeline_status_ids = redis.zrange(timeline_key, 0, -1)
    statuses            = Status.where(id: timeline_status_ids).select(:id, :reblog_of_id, :account_id).to_a
    reblogged_ids       = Status.where(id: statuses.filter_map(&:reblog_of_id), account: target_account).pluck(:id)
    with_mentions_ids   = Mention.active.where(status_id: statuses.flat_map { |s| [s.id, s.reblog_of_id] }.compact, account: target_account).pluck(:status_id)

    target_statuses = statuses.select do |status|
      status.account_id == target_account.id || reblogged_ids.include?(status.reblog_of_id) || with_mentions_ids.include?(status.id) || with_mentions_ids.include?(status.reblog_of_id)
    end

    target_statuses.each do |status|
      unpush_from_list(list, status)
    end
  end

  # Clear all statuses from or mentioning target_account from an account's lists
  # @param [Account] account
  # @param [Account] target_account
  # @return [void]
  def clear_from_lists(account, target_account)
    List.where(account: account).each do |list|
      clear_from_list(list, target_account)
    end
  end

  # Populate home feed of account from scratch
  # @param [Account] account
  # @return [void]
  def populate_home(account)
    limit        = FeedManager::MAX_ITEMS / 2
    aggregate    = account.user&.aggregates_reblogs?
    timeline_key = key(:home, account.id)

    account.statuses.limit(limit).each do |status|
      add_to_feed(:home, account.id, status, aggregate_reblogs: aggregate)
    end

    account.following.includes(:account_stat).reorder(nil).find_each do |target_account|
      if redis.zcard(timeline_key) >= limit
        oldest_home_score = redis.zrange(timeline_key, 0, 0, with_scores: true).first.last.to_i
        last_status_score = Mastodon::Snowflake.id_at(target_account.last_status_at)

        # If the feed is full and this account has not posted more recently
        # than the last item on the feed, then we can skip the whole account
        # because none of its statuses would stay on the feed anyway
        next if last_status_score < oldest_home_score
      end

      statuses = target_account.statuses.where(visibility: [:public, :unlisted, :private]).includes(:preloadable_poll, :media_attachments, :account, reblog: :account).limit(limit)
      crutches = build_crutches(account.id, statuses)

      statuses.each do |status|
        next if filter_from_home?(status, account.id, crutches)

        add_to_feed(:home, account.id, status, aggregate_reblogs: aggregate)
      end

      trim(:home, account.id)
    end
  end

  # Completely clear multiple feeds at once
  # @param [Symbol] type
  # @param [Array<Integer>] ids
  # @return [void]
  def clean_feeds!(type, ids)
    reblogged_id_sets = {}

    redis.pipelined do |pipeline|
      ids.each do |feed_id|
        reblog_key = key(type, feed_id, 'reblogs')
        # We collect a future for this: we don't block while getting
        # it, but we can iterate over it later.
        reblogged_id_sets[feed_id] = pipeline.zrange(reblog_key, 0, -1)
        pipeline.del(key(type, feed_id), reblog_key)
      end
    end

    # Remove all of the reblog tracking keys we just removed the
    # references to.
    keys_to_delete = reblogged_id_sets.flat_map do |feed_id, future|
      future.value.map do |reblogged_id|
        key(type, feed_id, "reblogs:#{reblogged_id}")
      end
    end

    redis.del(keys_to_delete) unless keys_to_delete.empty?

    nil
  end

  private

  # Trim a feed to maximum size by removing older items
  # @param [Symbol] type
  # @param [Integer] timeline_id
  # @return [void]
  def trim(type, timeline_id)
    timeline_key = key(type, timeline_id)
    reblog_key   = key(type, timeline_id, 'reblogs')

    # Remove any items past the MAX_ITEMS'th entry in our feed
    redis.zremrangebyrank(timeline_key, 0, -(FeedManager::MAX_ITEMS + 1))

    # Get the score of the REBLOG_FALLOFF'th item in our feed, and stop
    # tracking anything after it for deduplication purposes.
    falloff_rank  = FeedManager::REBLOG_FALLOFF
    falloff_range = redis.zrevrange(timeline_key, falloff_rank, falloff_rank, with_scores: true)
    falloff_score = falloff_range&.first&.last&.to_i

    return if falloff_score.nil?

    # Get any reblogs we might have to clean up after.
    redis.zrangebyscore(reblog_key, 0, falloff_score).each do |reblogged_id|
      # Remove it from the set of reblogs we're tracking *first* to avoid races.
      redis.zrem(reblog_key, reblogged_id)
      # Just drop any set we might have created to track additional reblogs.
      # This means that if this reblog is deleted, we won't automatically insert
      # another reblog, but also that any new reblog can be inserted into the
      # feed.
      redis.del(key(type, timeline_id, "reblogs:#{reblogged_id}"))
    end
  end

  # Check if there is a streaming API client connected
  # for the given feed
  # @param [String] timeline_key
  # @return [Boolean]
  def push_update_required?(timeline_key)
    redis.exists?("subscribed:#{timeline_key}")
  end

  # Check if the account is blocking or muting any of the given accounts
  # @param [Integer] receiver_id
  # @param [Array<Integer>] account_ids
  # @param [Symbol] context
  def blocks_or_mutes?(receiver_id, account_ids, context)
    Block.where(account_id: receiver_id, target_account_id: account_ids).any? ||
      (context == :home ? Mute.where(account_id: receiver_id, target_account_id: account_ids).any? : Mute.where(account_id: receiver_id, target_account_id: account_ids, hide_notifications: true).any?)
  end

  # Check if status should not be added to the home feed
  # @param [Status] status
  # @param [Integer] receiver_id
  # @param [Hash] crutches
  # @return [Boolean]
  def filter_from_home?(status, receiver_id, crutches, timeline_type = :home)
    return false if receiver_id == status.account_id
    return true  if status.reply? && (status.in_reply_to_id.nil? || status.in_reply_to_account_id.nil?)
    return true if timeline_type != :list && crutches[:exclusive_list_users][status.account_id].present?
    return true if crutches[:languages][status.account_id].present? && status.language.present? && !crutches[:languages][status.account_id].include?(status.language)

    check_for_blocks = crutches[:active_mentions][status.id] || []
    check_for_blocks.push(status.account_id)

    if status.reblog?
      check_for_blocks.push(status.reblog.account_id)
      check_for_blocks.concat(crutches[:active_mentions][status.reblog_of_id] || [])
    end

    return true if check_for_blocks.any? { |target_account_id| crutches[:blocking][target_account_id] || crutches[:muting][target_account_id] }
    return true if crutches[:blocked_by][status.account_id]

    if status.reply? && !status.in_reply_to_account_id.nil?                                                                      # Filter out if it's a reply
      should_filter   = !crutches[:following][status.in_reply_to_account_id]                                                     # and I'm not following the person it's a reply to
      should_filter &&= receiver_id != status.in_reply_to_account_id                                                             # and it's not a reply to me
      should_filter &&= status.account_id != status.in_reply_to_account_id                                                       # and it's not a self-reply

      return !!should_filter
    elsif status.reblog?                                                                                                         # Filter out a reblog
      should_filter   = crutches[:hiding_reblogs][status.account_id]                                                             # if the reblogger's reblogs are suppressed
      should_filter ||= crutches[:blocked_by][status.reblog.account_id]                                                          # or if the author of the reblogged status is blocking me
      should_filter ||= crutches[:domain_blocking][status.reblog.account.domain]                                                 # or the author's domain is blocked

      return !!should_filter
    end

    false
  end

  # Check if status should not be added to the mentions feed
  # @see NotifyService
  # @param [Status] status
  # @param [Integer] receiver_id
  # @return [Boolean]
  def filter_from_mentions?(status, receiver_id)
    return true if receiver_id == status.account_id

    # This filter is called from NotifyService, but already after the sender of
    # the notification has been checked for mute/block. Therefore, it's not
    # necessary to check the author of the toot for mute/block again
    check_for_blocks = status.active_mentions.pluck(:account_id)
    check_for_blocks.push(status.in_reply_to_account) if status.reply? && !status.in_reply_to_account_id.nil?

    should_filter   = blocks_or_mutes?(receiver_id, check_for_blocks, :mentions)                                                         # Filter if it's from someone I blocked, in reply to someone I blocked, or mentioning someone I blocked (or muted)
    should_filter ||= (status.account.silenced? && !Follow.where(account_id: receiver_id, target_account_id: status.account_id).exists?) # of if the account is silenced and I'm not following them

    should_filter
  end

  # Check if status should not be added to the list feed
  # @param [Status] status
  # @param [List] list
  # @return [Boolean]
  def filter_from_list?(status, list)
    if status.reply? && status.in_reply_to_account_id != status.account_id
      should_filter = status.in_reply_to_account_id != list.account_id
      should_filter &&= !list.show_followed?
      should_filter &&= !(list.show_list? && ListAccount.where(list_id: list.id, account_id: status.in_reply_to_account_id).exists?)

      return !!should_filter
    end

    false
  end

  # Check if a status should not be added to the home feed when it comes
  # from a followed hashtag
  # @param [Status] status
  # @param [Integer] receiver_id
  # @param [Hash] crutches
  # @return [Boolean]
  def filter_from_tags?(status, receiver_id, crutches)
    receiver_id == status.account_id || ((crutches[:active_mentions][status.id] || []) + [status.account_id]).any? { |target_account_id| crutches[:blocking][target_account_id] || crutches[:muting][target_account_id] } || crutches[:blocked_by][status.account_id] || crutches[:domain_blocking][status.account.domain]
  end

  # Adds a status to an account's feed, returning true if a status was
  # added, and false if it was not added to the feed. Note that this is
  # an internal helper: callers must call trim or push updates if
  # either action is appropriate.
  # @param [Symbol] timeline_type
  # @param [Integer] account_id
  # @param [Status] status
  # @param [Boolean] aggregate_reblogs
  # @return [Boolean]
  def add_to_feed(timeline_type, account_id, status, aggregate_reblogs: true)
    timeline_key = key(timeline_type, account_id)
    reblog_key   = key(timeline_type, account_id, 'reblogs')

    if status.reblog? && (aggregate_reblogs.nil? || aggregate_reblogs)
      # If the original status or a reblog of it is within
      # REBLOG_FALLOFF statuses from the top, do not re-insert it into
      # the feed
      rank = redis.zrevrank(timeline_key, status.reblog_of_id)

      return false if !rank.nil? && rank < FeedManager::REBLOG_FALLOFF

      # The ordered set at `reblog_key` holds statuses which have a reblog
      # in the top `REBLOG_FALLOFF` statuses of the timeline
      if redis.zadd(reblog_key, status.id, status.reblog_of_id, nx: true)
        # This is not something we've already seen reblogged, so we
        # can just add it to the feed (and note that we're reblogging it).
        redis.zadd(timeline_key, status.id, status.id)
      else
        # Another reblog of the same status was already in the
        # REBLOG_FALLOFF most recent statuses, so we note that this
        # is an "extra" reblog, by storing it in reblog_set_key.
        reblog_set_key = key(timeline_type, account_id, "reblogs:#{status.reblog_of_id}")
        redis.sadd(reblog_set_key, status.id)
        return false
      end
    else
      # A reblog may reach earlier than the original status because of the
      # delay of the worker delivering the original status, the late addition
      # by merging timelines, and other reasons.
      # If such a reblog already exists, just do not re-insert it into the feed.
      return false unless redis.zscore(reblog_key, status.id).nil?

      redis.zadd(timeline_key, status.id, status.id)
    end

    true
  end

  # Removes an individual status from a feed, correctly handling cases
  # with reblogs, and returning true if a status was removed. As with
  # `add_to_feed`, this does not trigger push updates, so callers must
  # do so if appropriate.
  # @param [Symbol] timeline_type
  # @param [Integer] account_id
  # @param [Status] status
  # @param [Boolean] aggregate_reblogs
  # @return [Boolean]
  def remove_from_feed(timeline_type, account_id, status, aggregate_reblogs: true)
    timeline_key = key(timeline_type, account_id)
    reblog_key   = key(timeline_type, account_id, 'reblogs')

    if status.reblog? && (aggregate_reblogs.nil? || aggregate_reblogs)
      # 1. If the reblogging status is not in the feed, stop.
      status_rank = redis.zrevrank(timeline_key, status.id)
      return false if status_rank.nil?

      # 2. Remove reblog from set of this status's reblogs.
      reblog_set_key = key(timeline_type, account_id, "reblogs:#{status.reblog_of_id}")

      redis.srem(reblog_set_key, status.id)
      redis.zrem(reblog_key, status.reblog_of_id)
      # 3. Re-insert another reblog or original into the feed if one
      # remains in the set. We could pick a random element, but this
      # set should generally be small, and it seems ideal to show the
      # oldest potential such reblog.
      other_reblog = redis.smembers(reblog_set_key).map(&:to_i).min

      redis.zadd(timeline_key, other_reblog, other_reblog) if other_reblog
      redis.zadd(reblog_key, other_reblog, status.reblog_of_id) if other_reblog

      # 4. Remove the reblogging status from the feed (as normal)
      # (outside conditional)
    else
      # If the original is getting deleted, no use for reblog references
      redis.del(key(timeline_type, account_id, "reblogs:#{status.id}"))
      redis.zrem(reblog_key, status.id)
    end

    redis.zrem(timeline_key, status.id)
  end

  # Pre-fetch various objects and relationships for given statuses that
  # are going to be checked by the filtering methods
  # @param [Integer] receiver_id
  # @param [Array<Status>] statuses
  # @return [Hash]
  def build_crutches(receiver_id, statuses)
    crutches = {}

    crutches[:active_mentions] = Mention.active.where(status_id: statuses.flat_map { |s| [s.id, s.reblog_of_id] }.compact).pluck(:status_id, :account_id).each_with_object({}) { |(id, account_id), mapping| (mapping[id] ||= []).push(account_id) }

    check_for_blocks = statuses.flat_map do |s|
      arr = crutches[:active_mentions][s.id] || []
      arr.push(s.account_id)

      if s.reblog?
        arr.push(s.reblog.account_id)
        arr.concat(crutches[:active_mentions][s.reblog_of_id] || [])
      end

      arr
    end

    lists = List.where(account_id: receiver_id, exclusive: true)

    crutches[:following]            = Follow.where(account_id: receiver_id, target_account_id: statuses.filter_map(&:in_reply_to_account_id)).pluck(:target_account_id).index_with(true)
    crutches[:languages]            = Follow.where(account_id: receiver_id, target_account_id: statuses.map(&:account_id)).pluck(:target_account_id, :languages).to_h
    crutches[:hiding_reblogs]       = Follow.where(account_id: receiver_id, target_account_id: statuses.filter_map { |s| s.account_id if s.reblog? }, show_reblogs: false).pluck(:target_account_id).index_with(true)
    crutches[:blocking]             = Block.where(account_id: receiver_id, target_account_id: check_for_blocks).pluck(:target_account_id).index_with(true)
    crutches[:muting]               = Mute.where(account_id: receiver_id, target_account_id: check_for_blocks).pluck(:target_account_id).index_with(true)
    crutches[:domain_blocking]      = AccountDomainBlock.where(account_id: receiver_id, domain: statuses.flat_map { |s| [s.account.domain, s.reblog&.account&.domain] }.compact).pluck(:domain).index_with(true)
    crutches[:blocked_by]           = Block.where(target_account_id: receiver_id, account_id: statuses.map { |s| [s.account_id, s.reblog&.account_id] }.flatten.compact).pluck(:account_id).index_with(true)
    crutches[:exclusive_list_users] = ListAccount.where(list: lists, account_id: statuses.map(&:account_id)).pluck(:account_id).index_with(true)

    crutches
  end
end
