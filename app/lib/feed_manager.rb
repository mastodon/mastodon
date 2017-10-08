# frozen_string_literal: true

require 'singleton'

class FeedManager
  include Singleton

  MAX_ITEMS = 400

  # Must be <= MAX_ITEMS or the tracking sets will grow forever
  REBLOG_FALLOFF = 40

  def key(type, id, subtype = nil)
    return "feed:#{type}:#{id}" unless subtype

    "feed:#{type}:#{id}:#{subtype}"
  end

  def filter?(timeline_type, status, receiver_id)
    if timeline_type == :home
      filter_from_home?(status, receiver_id)
    elsif timeline_type == :mentions
      filter_from_mentions?(status, receiver_id)
    else
      false
    end
  end

  def push(timeline_type, account, status)
    return false unless add_to_feed(timeline_type, account, status)

    trim(timeline_type, account.id)

    PushUpdateWorker.perform_async(account.id, status.id) if push_update_required?(timeline_type, account.id)

    true
  end

  def unpush(timeline_type, account, status)
    return false unless remove_from_feed(timeline_type, account, status)

    payload = Oj.dump(event: :delete, payload: status.id.to_s)
    Redis.current.publish("timeline:#{account.id}", payload)

    true
  end

  def trim(type, account_id)
    timeline_key = key(type, account_id)
    reblog_key = key(type, account_id, 'reblogs')
    # Remove any items past the MAX_ITEMS'th entry in our feed
    redis.zremrangebyrank(timeline_key, '0', (-(FeedManager::MAX_ITEMS + 1)).to_s)

    # Get the score of the REBLOG_FALLOFF'th item in our feed, and stop
    # tracking anything after it for deduplication purposes.
    falloff_rank = FeedManager::REBLOG_FALLOFF - 1
    falloff_range = redis.zrevrange(timeline_key, falloff_rank, falloff_rank, with_scores: true)
    falloff_score = falloff_range&.first&.last&.to_i || 0
    redis.zremrangebyscore(reblog_key, 0, falloff_score)
  end

  def push_update_required?(timeline_type, account_id)
    timeline_type != :home || redis.get("subscribed:timeline:#{account_id}").present?
  end

  def merge_into_timeline(from_account, into_account)
    timeline_key = key(:home, into_account.id)
    query        = from_account.statuses.limit(FeedManager::MAX_ITEMS / 4)

    if redis.zcard(timeline_key) >= FeedManager::MAX_ITEMS / 4
      oldest_home_score = redis.zrange(timeline_key, 0, 0, with_scores: true)&.first&.last&.to_i || 0
      query = query.where('id > ?', oldest_home_score)
    end

    query.each do |status|
      next if status.direct_visibility? || filter?(:home, status, into_account)
      add_to_feed(:home, into_account, status)
    end

    trim(:home, into_account.id)
  end

  def unmerge_from_timeline(from_account, into_account)
    timeline_key = key(:home, into_account.id)
    oldest_home_score = redis.zrange(timeline_key, 0, 0, with_scores: true)&.first&.last&.to_i || 0

    from_account.statuses.select('id, reblog_of_id').where('id > ?', oldest_home_score).reorder(nil).find_each do |status|
      unpush(:home, into_account, status)
    end
  end

  def clear_from_timeline(account, target_account)
    timeline_key = key(:home, account.id)
    timeline_status_ids = redis.zrange(timeline_key, 0, -1)
    target_statuses = Status.where(id: timeline_status_ids, account: target_account)

    target_statuses.each do |status|
      unpush(:home, account, status)
    end
  end

  def populate_feed(account)
    prepopulate_limit = FeedManager::MAX_ITEMS / 4
    statuses = Status.as_home_timeline(account).order(account_id: :desc).limit(prepopulate_limit)
    statuses.reverse_each do |status|
      next if filter_from_home?(status, account)
      add_to_feed(:home, account, status)
    end
  end

  private

  def redis
    Redis.current
  end

  def filter_from_home?(status, receiver_id)
    return true if status.reply? && (status.in_reply_to_id.nil? || status.in_reply_to_account_id.nil?)

    check_for_mutes = [status.account_id]
    check_for_mutes.concat([status.reblog.account_id]) if status.reblog?

    return true if Mute.where(account_id: receiver_id, target_account_id: check_for_mutes).any?

    check_for_blocks = status.mentions.pluck(:account_id)
    check_for_blocks.concat([status.reblog.account_id]) if status.reblog?

    return true if Block.where(account_id: receiver_id, target_account_id: check_for_blocks).any?

    if status.reply? && !status.in_reply_to_account_id.nil?                                                              # Filter out if it's a reply
      should_filter   = !Follow.where(account_id: receiver_id, target_account_id: status.in_reply_to_account_id).exists? # and I'm not following the person it's a reply to
      should_filter &&= receiver_id != status.in_reply_to_account_id                                                     # and it's not a reply to me
      should_filter &&= status.account_id != status.in_reply_to_account_id                                               # and it's not a self-reply
      return should_filter
    elsif status.reblog?                                                                                                 # Filter out a reblog
      should_filter   = Block.where(account_id: status.reblog.account_id, target_account_id: receiver_id).exists?        # or if the author of the reblogged status is blocking me
      should_filter ||= AccountDomainBlock.where(account_id: receiver_id, domain: status.reblog.account.domain).exists?  # or the author's domain is blocked
      return should_filter
    end

    false
  end

  def filter_from_mentions?(status, receiver_id)
    return true if receiver_id == status.account_id

    check_for_blocks = [status.account_id]
    check_for_blocks.concat(status.mentions.pluck(:account_id))
    check_for_blocks.concat([status.in_reply_to_account]) if status.reply? && !status.in_reply_to_account_id.nil?

    should_filter   = Block.where(account_id: receiver_id, target_account_id: check_for_blocks).any?                                     # Filter if it's from someone I blocked, in reply to someone I blocked, or mentioning someone I blocked
    should_filter ||= (status.account.silenced? && !Follow.where(account_id: receiver_id, target_account_id: status.account_id).exists?) # of if the account is silenced and I'm not following them

    should_filter
  end

  # Adds a status to an account's feed, returning true if a status was
  # added, and false if it was not added to the feed. Note that this is
  # an internal helper: callers must call trim or push updates if
  # either action is appropriate.
  def add_to_feed(timeline_type, account, status)
    timeline_key = key(timeline_type, account.id)
    reblog_key = key(timeline_type, account.id, 'reblogs')

    if status.reblog?
      # If the original status or a reblog of it is within
      # REBLOG_FALLOFF statuses from the top, do not re-insert it into
      # the feed
      rank = redis.zrevrank(timeline_key, status.reblog_of_id)
      return false if !rank.nil? && rank < FeedManager::REBLOG_FALLOFF

      reblog_rank = redis.zrevrank(reblog_key, status.reblog_of_id)
      return false unless reblog_rank.nil?

      redis.zadd(timeline_key, status.id, status.id)
      redis.zadd(reblog_key, status.id, status.reblog_of_id)
    else
      redis.zadd(timeline_key, status.id, status.id)
    end

    true
  end

  # Removes an individual status from a feed, correctly handling cases
  # with reblogs, and returning true if a status was removed. As with
  # `add_to_feed`, this does not trigger push updates, so callers must
  # do so if appropriate.
  def remove_from_feed(timeline_type, account, status)
    timeline_key = key(timeline_type, account.id)
    reblog_key = key(timeline_type, account.id, 'reblogs')

    if status.reblog?
      # 1. If the reblogging status is not in the feed, stop.
      status_rank = redis.zrevrank(timeline_key, status.id)
      return false if status_rank.nil?

      # 2. Remove the reblogged status from the `:reblogs` zset.
      redis.zrem(reblog_key, status.reblog_of_id)

      # 3. Add the reblogged status to the feed using the reblogging
      # status' ID as its score, and the reblogged status' ID as its
      # value.
      redis.zadd(timeline_key, status.id, status.reblog_of_id)

      # 4. Remove the reblogging status from the feed (as normal)
    end

    redis.zrem(timeline_key, status.id)
  end
end
