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
    elsif timeline_type == :public
      filter_from_public?(status, receiver)
    else
      false
    end
  end

  def push(timeline_type, account, status)
    redis.zadd(key(timeline_type, account.id), status.id, status.reblog? ? status.reblog_of_id : status.id)
    trim(timeline_type, account.id)
    broadcast(account.id, type: 'update', timeline: timeline_type, message: inline_render(account, status))
  end

  def broadcast(timeline_id, options = {})
    ActionCable.server.broadcast("timeline:#{timeline_id}", options)
  end

  def trim(type, account_id)
    return unless redis.zcard(key(type, account_id)) > FeedManager::MAX_ITEMS
    last = redis.zrevrange(key(type, account_id), FeedManager::MAX_ITEMS - 1, FeedManager::MAX_ITEMS - 1)
    redis.zremrangebyscore(key(type, account_id), '-inf', "(#{last.last}")
  end

  def inline_render(target_account, status)
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

    Rabl::Renderer.new('api/v1/statuses/show', status, view_path: 'app/views', format: :json, scope: rabl_scope.new(target_account)).render
  end

  private

  def redis
    $redis
  end

  def filter_from_home?(status, receiver)
    should_filter = false

    if status.reply? && !status.thread.account.nil?                                     # Filter out if it's a reply
      should_filter = !receiver.following?(status.thread.account)                       # and I'm not following the person it's a reply to
      should_filter = should_filter && !(receiver.id == status.thread.account_id)       # and it's not a reply to me
      should_filter = should_filter && !(status.account_id == status.thread.account_id) # and it's not a self-reply
    elsif status.reblog?                                                                # Filter out a reblog
      should_filter = receiver.blocking?(status.reblog.account)                         # if I'm blocking the reblogged person
    end

    should_filter
  end

  def filter_from_mentions?(status, receiver)
    should_filter = receiver.id == status.account_id                    # Filter if I'm mentioning myself
    should_filter = should_filter || receiver.blocking?(status.account) # or it's from someone I blocked
    should_filter
  end

  def filter_from_public?(status, receiver)
    should_filter = receiver.blocking?(status.account)

    if status.reply? && !status.thread.account.nil?
      should_filter = should_filter || receiver.blocking?(status.thread.account)
    elsif status.reblog?
      should_filter = should_filter || receiver.blocking?(status.reblog.account)
    end

    should_filter
  end
end
