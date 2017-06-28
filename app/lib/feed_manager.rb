# frozen_string_literal: true

require 'singleton'

class FeedManager
  include Singleton

  MAX_ITEMS = 400

  def key(type, id)
    "feed:#{type}:#{id}"
  end

  def filter_subscribers(status, subscribers)
    return Account.none if status.reply? && status.in_reply_to_id.nil?

    check_for_mutes = [status.account]
    check_for_mutes.concat([status.reblog.account]) if status.reblog?

    check_for_blocks = status.mentions.map(&:account)
    check_for_blocks.concat([status.reblog.account]) if status.reblog?

    subscribers = subscribers.where.not(id: Block.where(target_account: check_for_blocks).select(:account_id))
                             .where.not(id: Mute.where(target_account: check_for_mutes).select(:account_id))

    if status.reply? && !status.in_reply_to_account_id.nil?                                              # Filter out if it's a reply
      if status.account_id != status.in_reply_to_account_id                                              # and it's not a self-reply
        subscribers = subscribers.joins(:following)

        # Inconsistent results with #or in ActiveRecord::Relation with respect to documentation Issue #24055 rails/rails
        # https://github.com/rails/rails/issues/24055
        subscribers = subscribers.where.not(follows: { target_account_id: nil })

        subscribers = subscribers.where(follows: { target_account_id: status.in_reply_to_account_id })   # unless I'm following the person it's a reply to
                                 .or(subscribers.where(id: status.in_reply_to_account_id))               # unless it's a reply to me
      end
    elsif status.reblog?                                                                                                          # Filter out a reblog
      subscribers = subscribers.where.not(id: Block.where(account: status.reblog.account).select(:target_account_id))             # if the author of the reblogged status is blocking me
                               .where.not(id: AccountDomainBlock.where(domain: status.reblog.account.domain).select(:account_id)) # or if the author's domain is blocked
    end

    subscribers
  end

  def filter_mentions(status)
    check_for_blocks = [status.account]
    check_for_blocks.concat(status.mentions.map(&:account))
    check_for_blocks.concat([status.in_reply_to_account]) if status.reply? && !status.in_reply_to_account.nil?

    mentions = status.mentions
                     .where.not(account_id: status.account_id)                                                 # I'm not mentioning myself
                     .where.not(account_id: Block.where(target_account: check_for_blocks).select(:account_id)) # It's not from someone I blocked, in reply to someone I blocked, nor mentioning someone I blocked

    if status.account.silenced?                                    # Filter out if the account is silenced
      mentions = mentions.joins(:account)
                         .merge(Account.following(status.account)) # unless I'm following them
    end

    mentions
  end

  def push(timeline_type, account, status)
    push_bulk(timeline_type, [account], status)
  end

  def push_bulk(timeline_type, accounts, status)
    account_ids = accounts.pluck(:id)
    return if account_ids.empty?

    if status.reblog?
      ranks = redis.pipelined do
        account_ids.each do |account_id|
          redis.zrevrank(key(timeline_type, account_id), status.reblog_of_id)
        end
      end

      account_indexes = account_ids.size.times.lazy.reject do |index|
        rank = ranks[index]
        # If the original status is within 40 statuses from top, do not re-insert it into the feed
        rank.present? && rank < 40
      end

      filtered_account_ids = account_indexes.map do |index|
        account_id = account_ids[index]
        redis.zadd(key(timeline_type, account_id), status.id, status.reblog_of_id)
        account_id
      end

      redis.pipelined do
        account_ids = filtered_account_ids.to_a
      end
    else
      timeline_keys = nil

      redis.pipelined do
        timeline_keys = account_ids.map do |account_id|
          timeline_key = key(timeline_type, account_id)
          redis.zadd(timeline_key, status.id, status.id)
          timeline_key
        end
      end

      trim_bulk(timeline_keys)
    end

    subscribing_account_ids(timeline_type, account_ids).each do |account_id|
      PushUpdateWorker.perform_async(account_id, status.id)
    end
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
        next if status.direct_visibility? || filter_subscribers(status, Account.where(id: into_account.id)).empty?
        redis.zadd(timeline_key, status.id, status.id)
      end
    end

    trim_bulk([key(:home, into_account.id)])
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

  def subscribing_account_ids(timeline_type, account_ids)
    if timeline_type == :home
      subscribeds = subscribed_bulk(account_ids)

      account_ids.size.times.lazy
                 .select { |index| subscribeds[index].present? }
                 .map { |index| account_ids[index] }
    else
      account_ids
    end
  end

  def subscribed_bulk(account_ids)
    keys = account_ids.map { |account_id| "subscribed:timeline:#{account_id}" }
    redis.mget(keys)
  end

  def trim_bulk(timeline_keys)
    timeline_lasts = redis.pipelined do
      timeline_keys.each do |timeline_key|
        redis.zrevrange(timeline_key, FeedManager::MAX_ITEMS - 1, FeedManager::MAX_ITEMS - 1)
      end
    end

    redis.pipelined do
      timeline_keys.each_with_index do |timeline_key, index|
        last = timeline_lasts[index]
        redis.zremrangebyscore(timeline_key, '-inf', "(#{last.last}") if last.any?
      end
    end
  end

  def redis
    Redis.current
  end
end
