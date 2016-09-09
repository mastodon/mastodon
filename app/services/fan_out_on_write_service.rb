class FanOutOnWriteService < BaseService
  # Push a status into home and mentions feeds
  # @param [Status] status
  def call(status)
    deliver_to_self(status) if status.account.local?
    deliver_to_followers(status)
    deliver_to_mentioned(status)
  end

  private

  def deliver_to_self(status)
    push(:home, status.account, status)
  end

  def deliver_to_followers(status)
    status.account.followers.each do |follower|
      next if !follower.local? || FeedManager.instance.filter_status?(status, follower)
      push(:home, follower, status)
    end
  end

  def deliver_to_mentioned(status)
    status.mentions.each do |mention|
      mentioned_account = mention.account
      next unless mentioned_account.local?
      push(:mentions, mentioned_account, status)
    end
  end

  def push(type, receiver, status)
    redis.zadd(FeedManager.instance.key(type, receiver.id), status.id, status.id)
    trim(type, receiver)
    ActionCable.server.broadcast("timeline:#{receiver.id}", type: 'update', timeline: type, message: inline_render(receiver, status))
  end

  def trim(type, receiver)
    return unless redis.zcard(FeedManager.instance.key(type, receiver.id)) > FeedManager::MAX_ITEMS

    last = redis.zrevrange(FeedManager.instance.key(type, receiver.id), FeedManager::MAX_ITEMS - 1, FeedManager::MAX_ITEMS - 1)
    redis.zremrangebyscore(FeedManager.instance.key(type, receiver.id), '-inf', "(#{last.last}")
  end

  def redis
    $redis
  end

  def inline_render(receiver, status)
    rabl_scope = Class.new(BaseService) do
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

    Rabl::Renderer.new('api/statuses/show', status,  view_path: 'app/views', format: :json, scope: rabl_scope.new(receiver)).render
  end
end
