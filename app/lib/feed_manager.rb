# frozen_string_literal: true

require 'singleton'

class FeedManager
  include Singleton

  MAX_ITEMS = 400

  def key(type, id)
    "feed:#{type}:#{id}"
  end

  def filter?(timeline_type, status, receiver)
    if timeline_type == :home
      filter_from_home?(status, receiver)
    elsif timeline_type == :mentions
      filter_from_mentions?(status, receiver)
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
    redis.zremrangebyrank(key(type, account_id), '0', (-(FeedManager::MAX_ITEMS + 1)).to_s)
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

  def filter_from_home?(status, receiver)
    if status.reply?
      # Filter out if it's a reply to a status we don't know about
      return true if status.in_reply_to_account.nil? || status.in_reply_to_id.nil?

      # Show replies in my home timeline only if i'm following the user
      reply_visibility   = receiver.following?(status.in_reply_to_account)
      # or it's a reply to me
      reply_visibility ||= receiver.id == status.in_reply_to_account_id
      # or it's a self-reply
      reply_visibility ||= status.account_id == status.in_reply_to_account_id
      return true unless reply_visibility

    elsif status.reblog?
      # Filter out a reblog if the author of the reblogged status is blocking me
      return true if status.reblog.account.blocking? receiver
      # or the author's domain is blocked
      return true if receiver.domain_blocking? status.reblog.account.domain
    end

    # filter the status if I'm muting the creator or the original author
    check_for_mutes = [status.account_id, status.reblog&.account_id]
    return true if receiver.muting? check_for_mutes.compact

    # filter the status if I'm blocking anyone who was mentioned or the original author
    check_for_blocks = status.mentions.pluck(:account_id) + [status.reblog&.account_id]
    return true if receiver.blocking? check_for_blocks.compact

    false
  end

  def filter_from_mentions?(status, receiver)

    # Filter if I'm mentioning myself
    return true if receiver.id == status.account_id

    # or it's from someone I blocked, in reply to someone I blocked, or mentioning someone I blocked
    check_for_blocks  = [status.account_id, status.in_reply_to_account_id]
    check_for_blocks += status.mentions.pluck(:account_id)
    return true if receiver.blocking? check_for_blocks.compact

    # of if the account is silenced and I'm not following them
    return true if status.account.silenced? && !receiver.following?(status.account)

    false
  end
end
