# frozen_string_literal: true

require 'singleton'

class FeedManager
  include Singleton

  MAX_ITEMS = 800

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

    broadcast(account.id, event: 'update', payload: inline_render(account, 'api/v1/statuses/show', status))
  end

  def broadcast(timeline_id, options = {})
    options[:queued_at] = (Time.now.to_f * 1000.0).to_i
    ActionCable.server.broadcast("timeline:#{timeline_id}", options)
  end

  def trim(type, account_id)
    return unless redis.zcard(key(type, account_id)) > FeedManager::MAX_ITEMS
    last = redis.zrevrange(key(type, account_id), FeedManager::MAX_ITEMS - 1, FeedManager::MAX_ITEMS - 1)
    redis.zremrangebyscore(key(type, account_id), '-inf', "(#{last.last}")
  end

  def merge_into_timeline(from_account, into_account)
    timeline_key = key(:home, into_account.id)

    from_account.statuses.limit(MAX_ITEMS).each do |status|
      next if filter?(:home, status, into_account)
      redis.zadd(timeline_key, status.id, status.id)
    end

    trim(:home, into_account.id)
  end

  def unmerge_from_timeline(from_account, into_account)
    timeline_key = key(:home, into_account.id)

    from_account.statuses.select('id').find_each do |status|
      redis.zrem(timeline_key, status.id)
      redis.zremrangebyscore(timeline_key, status.id, status.id)
    end
  end

  def inline_render(target_account, template, object)
    rabl_scope = Class.new do
      include RoutingHelper

      def initialize(account)
        @account = account
      end

      def current_user
        @account.try(:user)
      end

      def current_account
        @account
      end
    end

    Rabl::Renderer.new(template, object, view_path: 'app/views', format: :json, scope: rabl_scope.new(target_account)).render
  end

  private

  def redis
    Redis.current
  end

  def filter_from_home?(status, receiver)
    should_filter = false

    if status.reply? && status.in_reply_to_id.nil?
      should_filter = true
    elsif status.reply? && !status.in_reply_to_account_id.nil?                # Filter out if it's a reply
      should_filter   = !receiver.following?(status.in_reply_to_account)      # and I'm not following the person it's a reply to
      should_filter &&= !(receiver.id == status.in_reply_to_account_id)       # and it's not a reply to me
      should_filter &&= !(status.account_id == status.in_reply_to_account_id) # and it's not a self-reply
    elsif status.reblog?                                                      # Filter out a reblog
      should_filter = receiver.blocking?(status.reblog.account)               # if I'm blocking the reblogged person
    end

    should_filter ||= receiver.blocking?(status.mentions.map(&:account_id))   # or if it mentions someone I blocked

    should_filter
  end

  def filter_from_mentions?(status, receiver)
    should_filter   = receiver.id == status.account_id                                      # Filter if I'm mentioning myself
    should_filter ||= receiver.blocking?(status.account)                                    # or it's from someone I blocked
    should_filter ||= receiver.blocking?(status.mentions.includes(:account).map(&:account)) # or if it mentions someone I blocked
    should_filter ||= (status.account.silenced? && !receiver.following?(status.account))    # of if the account is silenced and I'm not following them

    if status.reply? && !status.in_reply_to_account_id.nil?                                 # or it's a reply
      should_filter ||= receiver.blocking?(status.in_reply_to_account)                      # to a user I blocked
    end

    should_filter
  end
end
