require 'singleton'

class FeedManager
  include Singleton

  MAX_ITEMS = 800

  def key(type, id)
    "feed:#{type}:#{id}"
  end

  # Filter status out of the home feed if it is a reply to someone the user doesn't follow
  def filter_status?(status, follower)
    replied_to_user = status.reply? ? status.thread.account : nil
    (status.reply? && !(follower.id == replied_to_user.id || replied_to_user.id == status.account_id || follower.following?(replied_to_user)))
  end

  def push(timeline_type, account, status)
    redis.zadd(key(timeline_type, account.id), status.id, status.id)
    trim(timeline_type, account.id)
    broadcast(account.id, type: 'update', timeline: timeline_type, message: inline_render(account, status))
  end

  def broadcast(account_id, options = {})
    ActionCable.server.broadcast("timeline:#{account_id}", options)
  end

  def trim(type, account_id)
    return unless redis.zcard(key(type, account_id)) > FeedManager::MAX_ITEMS
    last = redis.zrevrange(key(type, account_id), FeedManager::MAX_ITEMS - 1, FeedManager::MAX_ITEMS - 1)
    redis.zremrangebyscore(key(type, account_id), '-inf', "(#{last.last}")
  end

  private

  def redis
    $redis
  end

  def inline_render(target_account, status)
    rabl_scope = Class.new do
      include RoutingHelper

      def initialize(account)
        @account = account
      end

      def current_user
        @account.user
      end

      def current_account
        @account
      end
    end

    Rabl::Renderer.new('api/statuses/show', status,  view_path: 'app/views', format: :json, scope: rabl_scope.new(target_account)).render
  end
end
