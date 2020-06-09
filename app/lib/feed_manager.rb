# frozen_string_literal: true

require 'singleton'

class FeedManager
  include Singleton
  include Redisable

  MAX_ITEMS = 400

  # Must be <= MAX_ITEMS or the tracking sets will grow forever
  REBLOG_FALLOFF = 40

  def with_active_accounts(&block)
    Account.joins(:user).where('users.current_sign_in_at > ?', User::ACTIVE_DURATION.ago).find_each(&block)
  end

  def key(type, id, subtype = nil)
    return "feed:#{type}:#{id}" unless subtype

    "feed:#{type}:#{id}:#{subtype}"
  end

  def filter?(timeline_type, status, receiver_id)
    if timeline_type == :home
      filter_from_home?(status, receiver_id, build_crutches(receiver_id, [status]))
    elsif timeline_type == :mentions
      filter_from_mentions?(status, receiver_id)
    else
      false
    end
  end

  def push_to_home(account, status)
    return false unless add_to_feed(:home, account.id, status, account.user&.aggregates_reblogs?)

    trim(:home, account.id)
    PushUpdateWorker.perform_async(account.id, status.id, "timeline:#{account.id}") if push_update_required?("timeline:#{account.id}")
    true
  end

  def unpush_from_home(account, status)
    return false unless remove_from_feed(:home, account.id, status, account.user&.aggregates_reblogs?)

    redis.publish("timeline:#{account.id}", Oj.dump(event: :delete, payload: status.id.to_s))
    true
  end

  def push_to_list(list, status)
    if status.reply? && status.in_reply_to_account_id != status.account_id
      should_filter = status.in_reply_to_account_id != list.account_id
      should_filter &&= !ListAccount.where(list_id: list.id, account_id: status.in_reply_to_account_id).exists?
      return false if should_filter
    end

    return false unless add_to_feed(:list, list.id, status, list.account.user&.aggregates_reblogs?)

    trim(:list, list.id)
    PushUpdateWorker.perform_async(list.account_id, status.id, "timeline:list:#{list.id}") if push_update_required?("timeline:list:#{list.id}")
    true
  end

  def unpush_from_list(list, status)
    return false unless remove_from_feed(:list, list.id, status, list.account.user&.aggregates_reblogs?)

    redis.publish("timeline:list:#{list.id}", Oj.dump(event: :delete, payload: status.id.to_s))
    true
  end

  def trim(type, account_id)
    timeline_key = key(type, account_id)
    reblog_key   = key(type, account_id, 'reblogs')

    # Remove any items past the MAX_ITEMS'th entry in our feed
    redis.zremrangebyrank(timeline_key, 0, -(FeedManager::MAX_ITEMS + 1))

    # Get the score of the REBLOG_FALLOFF'th item in our feed, and stop
    # tracking anything after it for deduplication purposes.
    falloff_rank  = FeedManager::REBLOG_FALLOFF - 1
    falloff_range = redis.zrevrange(timeline_key, falloff_rank, falloff_rank, with_scores: true)
    falloff_score = falloff_range&.first&.last&.to_i || 0

    # Get any reblogs we might have to clean up after.
    redis.zrangebyscore(reblog_key, 0, falloff_score).each do |reblogged_id|
      # Remove it from the set of reblogs we're tracking *first* to avoid races.
      redis.zrem(reblog_key, reblogged_id)
      # Just drop any set we might have created to track additional reblogs.
      # This means that if this reblog is deleted, we won't automatically insert
      # another reblog, but also that any new reblog can be inserted into the
      # feed.
      redis.del(key(type, account_id, "reblogs:#{reblogged_id}"))
    end
  end

  def merge_into_timeline(from_account, into_account)
    timeline_key = key(:home, into_account.id)
    aggregate    = into_account.user&.aggregates_reblogs?
    query        = from_account.statuses.where(visibility: [:public, :unlisted, :private]).includes(:preloadable_poll, reblog: :account).limit(FeedManager::MAX_ITEMS / 4)

    if redis.zcard(timeline_key) >= FeedManager::MAX_ITEMS / 4
      oldest_home_score = redis.zrange(timeline_key, 0, 0, with_scores: true).first.last.to_i
      query = query.where('id > ?', oldest_home_score)
    end

    statuses = query.to_a
    crutches = build_crutches(into_account.id, statuses)

    statuses.each do |status|
      next if filter_from_home?(status, into_account, crutches)

      add_to_feed(:home, into_account.id, status, aggregate)
    end

    trim(:home, into_account.id)
  end

  def unmerge_from_timeline(from_account, into_account)
    timeline_key      = key(:home, into_account.id)
    oldest_home_score = redis.zrange(timeline_key, 0, 0, with_scores: true)&.first&.last&.to_i || 0

    from_account.statuses.select('id, reblog_of_id').where('id > ?', oldest_home_score).reorder(nil).find_each do |status|
      remove_from_feed(:home, into_account.id, status, into_account.user&.aggregates_reblogs?)
    end
  end

  def clear_from_timeline(account, target_account)
    timeline_key        = key(:home, account.id)
    timeline_status_ids = redis.zrange(timeline_key, 0, -1)
    target_statuses     = Status.where(id: timeline_status_ids, account: target_account)

    target_statuses.each do |status|
      unpush_from_home(account, status)
    end
  end

  def populate_feed(account)
    limit        = FeedManager::MAX_ITEMS / 2
    aggregate    = account.user&.aggregates_reblogs?
    timeline_key = key(:home, account.id)

    account.statuses.where.not(visibility: :direct).limit(limit).each do |status|
      add_to_feed(:home, account.id, status, aggregate)
    end

    account.following.includes(:account_stat).find_each do |target_account|
      if redis.zcard(timeline_key) >= limit
        oldest_home_score = redis.zrange(timeline_key, 0, 0, with_scores: true).first.last.to_i
        last_status_score = Mastodon::Snowflake.id_at(account.last_status_at)

        # If the feed is full and this account has not posted more recently
        # than the last item on the feed, then we can skip the whole account
        # because none of its statuses would stay on the feed anyway
        next if last_status_score < oldest_home_score
      end

      statuses = target_account.statuses.where(visibility: [:public, :unlisted, :private]).includes(:preloadable_poll, reblog: :account).limit(limit)
      crutches = build_crutches(account.id, statuses)

      statuses.each do |status|
        next if filter_from_home?(status, account.id, crutches)

        add_to_feed(:home, account.id, status, aggregate)
      end

      trim(:home, account.id)
    end
  end

  private

  def push_update_required?(timeline_id)
    redis.exists("subscribed:#{timeline_id}")
  end

  def blocks_or_mutes?(receiver_id, account_ids, context)
    Block.where(account_id: receiver_id, target_account_id: account_ids).any? ||
      (context == :home ? Mute.where(account_id: receiver_id, target_account_id: account_ids).any? : Mute.where(account_id: receiver_id, target_account_id: account_ids, hide_notifications: true).any?)
  end

  def filter_from_home?(status, receiver_id, crutches)
    return false if receiver_id == status.account_id
    return true  if status.reply? && (status.in_reply_to_id.nil? || status.in_reply_to_account_id.nil?)
    return true  if phrase_filtered?(status, receiver_id, :home)

    check_for_blocks = crutches[:active_mentions][status.id] || []
    check_for_blocks.concat([status.account_id])

    if status.reblog?
      check_for_blocks.concat([status.reblog.account_id])
      check_for_blocks.concat(crutches[:active_mentions][status.reblog_of_id] || [])
    end

    return true if check_for_blocks.any? { |target_account_id| crutches[:blocking][target_account_id] || crutches[:muting][target_account_id] }

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

  def filter_from_mentions?(status, receiver_id)
    return true if receiver_id == status.account_id
    return true if phrase_filtered?(status, receiver_id, :notifications)

    # This filter is called from NotifyService, but already after the sender of
    # the notification has been checked for mute/block. Therefore, it's not
    # necessary to check the author of the toot for mute/block again
    check_for_blocks = status.active_mentions.pluck(:account_id)
    check_for_blocks.concat([status.in_reply_to_account]) if status.reply? && !status.in_reply_to_account_id.nil?

    should_filter   = blocks_or_mutes?(receiver_id, check_for_blocks, :mentions)                                                         # Filter if it's from someone I blocked, in reply to someone I blocked, or mentioning someone I blocked (or muted)
    should_filter ||= (status.account.silenced? && !Follow.where(account_id: receiver_id, target_account_id: status.account_id).exists?) # of if the account is silenced and I'm not following them

    should_filter
  end

  def phrase_filtered?(status, receiver_id, context)
    active_filters = Rails.cache.fetch("filters:#{receiver_id}") { CustomFilter.where(account_id: receiver_id).active_irreversible.to_a }.to_a

    active_filters.select! { |filter| filter.context.include?(context.to_s) && !filter.expired? }

    active_filters.map! do |filter|
      if filter.whole_word
        sb = filter.phrase =~ /\A[[:word:]]/ ? '\b' : ''
        eb = filter.phrase =~ /[[:word:]]\z/ ? '\b' : ''

        /(?mix:#{sb}#{Regexp.escape(filter.phrase)}#{eb})/
      else
        /#{Regexp.escape(filter.phrase)}/i
      end
    end

    return false if active_filters.empty?

    combined_regex = active_filters.reduce { |memo, obj| Regexp.union(memo, obj) }
    status         = status.reblog if status.reblog?

    combined_text = [
      Formatter.instance.plaintext(status),
      status.spoiler_text,
      status.preloadable_poll ? status.preloadable_poll.options.join("\n\n") : nil,
      status.media_attachments.map(&:description).join("\n\n"),
    ].compact.join("\n\n")

    !combined_regex.match(combined_text).nil?
  end

  # Adds a status to an account's feed, returning true if a status was
  # added, and false if it was not added to the feed. Note that this is
  # an internal helper: callers must call trim or push updates if
  # either action is appropriate.
  def add_to_feed(timeline_type, account_id, status, aggregate_reblogs = true)
    timeline_key = key(timeline_type, account_id)
    reblog_key   = key(timeline_type, account_id, 'reblogs')

    if status.reblog? && (aggregate_reblogs.nil? || aggregate_reblogs)
      # If the original status or a reblog of it is within
      # REBLOG_FALLOFF statuses from the top, do not re-insert it into
      # the feed
      rank = redis.zrevrank(timeline_key, status.reblog_of_id)

      return false if !rank.nil? && rank < FeedManager::REBLOG_FALLOFF

      reblog_rank = redis.zrevrank(reblog_key, status.reblog_of_id)

      if reblog_rank.nil?
        # This is not something we've already seen reblogged, so we
        # can just add it to the feed (and note that we're
        # reblogging it).
        redis.zadd(timeline_key, status.id, status.id)
        redis.zadd(reblog_key, status.id, status.reblog_of_id)
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
      # delay of the worker deliverying the original status, the late addition
      # by merging timelines, and other reasons.
      # If such a reblog already exists, just do not re-insert it into the feed.
      rank = redis.zrevrank(reblog_key, status.id)

      return false unless rank.nil?

      redis.zadd(timeline_key, status.id, status.id)
    end

    true
  end

  # Removes an individual status from a feed, correctly handling cases
  # with reblogs, and returning true if a status was removed. As with
  # `add_to_feed`, this does not trigger push updates, so callers must
  # do so if appropriate.
  def remove_from_feed(timeline_type, account_id, status, aggregate_reblogs = true)
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

  def build_crutches(receiver_id, statuses)
    crutches = {}

    crutches[:active_mentions] = Mention.active.where(status_id: statuses.flat_map { |s| [s.id, s.reblog_of_id] }.compact).pluck(:status_id, :account_id).each_with_object({}) { |(id, account_id), mapping| (mapping[id] ||= []).push(account_id) }

    check_for_blocks = statuses.flat_map do |s|
      arr = crutches[:active_mentions][s.id] || []
      arr.concat([s.account_id])

      if s.reblog?
        arr.concat([s.reblog.account_id])
        arr.concat(crutches[:active_mentions][s.reblog_of_id] || [])
      end

      arr
    end

    crutches[:following]       = Follow.where(account_id: receiver_id, target_account_id: statuses.map(&:in_reply_to_account_id).compact).pluck(:target_account_id).each_with_object({}) { |id, mapping| mapping[id] = true }
    crutches[:hiding_reblogs]  = Follow.where(account_id: receiver_id, target_account_id: statuses.map { |s| s.account_id if s.reblog? }.compact, show_reblogs: false).pluck(:target_account_id).each_with_object({}) { |id, mapping| mapping[id] = true }
    crutches[:blocking]        = Block.where(account_id: receiver_id, target_account_id: check_for_blocks).pluck(:target_account_id).each_with_object({}) { |id, mapping| mapping[id] = true }
    crutches[:muting]          = Mute.where(account_id: receiver_id, target_account_id: check_for_blocks).pluck(:target_account_id).each_with_object({}) { |id, mapping| mapping[id] = true }
    crutches[:domain_blocking] = AccountDomainBlock.where(account_id: receiver_id, domain: statuses.map { |s| s.reblog&.account&.domain }.compact).pluck(:domain).each_with_object({}) { |domain, mapping| mapping[domain] = true }
    crutches[:blocked_by]      = Block.where(target_account_id: receiver_id, account_id: statuses.map { |s| s.reblog&.account_id }.compact).pluck(:account_id).each_with_object({}) { |id, mapping| mapping[id] = true }

    crutches
  end
end
