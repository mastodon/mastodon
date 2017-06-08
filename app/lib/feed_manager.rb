# frozen_string_literal: true

require 'singleton'

class FeedManager
  include Singleton

  MAX_ITEMS = 400

  def key(type, id)
    "feed:#{type}:#{id}"
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
    timeline_key = key(timeline_type, account.id)

    if status.reblog?
      # If the original status is within 40 statuses from top, do not re-insert it into the feed
      rank = redis.zrevrank(timeline_key, status.reblog_of_id)
      return if !rank.nil? && rank < 40
      redis.zadd(timeline_key, status.id, status.reblog_of_id)
    else
      redis.zadd(timeline_key, status.id, status.id)
      trim(timeline_type, account.id)
    end

    PushUpdateWorker.perform_async(account.id, status.id) if push_update_required?(timeline_type, account.id)
  end

  def trim(type, account_id)
    return unless redis.zcard(key(type, account_id)) > FeedManager::MAX_ITEMS
    last = redis.zrevrange(key(type, account_id), FeedManager::MAX_ITEMS - 1, FeedManager::MAX_ITEMS - 1)
    redis.zremrangebyscore(key(type, account_id), '-inf', "(#{last.last}")
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

    redis.pipelined do
      query.each do |status|
        next if status.direct_visibility? || filter?(:home, status, into_account)
        redis.zadd(timeline_key, status.id, status.id)
      end
    end

    trim(:home, into_account.id)
  end

  def unmerge_from_timeline(from_account, into_account)
    timeline_key = key(:home, into_account.id)
    oldest_home_score = redis.zrange(timeline_key, 0, 0, with_scores: true)&.first&.last&.to_i || 0

    from_account.statuses.select('id').where('id > ?', oldest_home_score).reorder(nil).find_in_batches do |statuses|
      redis.pipelined do
        statuses.each do |status|
          redis.zrem(timeline_key, status.id)
          redis.zremrangebyscore(timeline_key, status.id, status.id)
        end
      end
    end
  end

  def clear_from_timeline(account, target_account)
    timeline_key = key(:home, account.id)
    timeline_status_ids = redis.zrange(timeline_key, 0, -1)
    target_status_ids = Status.where(id: timeline_status_ids, account: target_account).ids

    redis.zrem(timeline_key, target_status_ids) if target_status_ids.present?
  end

  private

  def redis
    Redis.current
  end

  def filter_from_home?(status, receiver_id)
    return true if status.reply? && status.in_reply_to_id.nil?

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
    check_for_blocks = [status.account_id]
    check_for_blocks.concat(status.mentions.pluck(:account_id))
    check_for_blocks.concat([status.in_reply_to_account]) if status.reply? && !status.in_reply_to_account_id.nil?

    should_filter   = receiver_id == status.account_id                                                                                   # Filter if I'm mentioning myself
    should_filter ||= Block.where(account_id: receiver_id, target_account_id: check_for_blocks).any?                                     # or it's from someone I blocked, in reply to someone I blocked, or mentioning someone I blocked
    should_filter ||= (status.account.silenced? && !Follow.where(account_id: receiver_id, target_account_id: status.account_id).exists?) # of if the account is silenced and I'm not following them

    should_filter
  end
end
