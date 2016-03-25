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
    push(:home, status.account.id, status)
  end

  def deliver_to_followers(status)
    status.account.followers.each do |follower|
      next if !follower.local? || FeedManager.filter_status?(status, follower)
      push(:home, follower.id, status)
    end
  end

  def deliver_to_mentioned(status)
    status.mentions.each do |mention|
      mentioned_account = mention.account
      next unless mentioned_account.local?
      push(:mentions, mentioned_account.id, status)
    end
  end

  def push(type, receiver_id, status)
    redis.zadd(FeedManager.key(type, receiver_id), status.id, status.id)
    trim(type, receiver_id)
  end

  def trim(type, receiver_id)
    return unless redis.zcard(FeedManager.key(type, receiver_id)) > FeedManager::MAX_ITEMS

    last = redis.zrevrange(FeedManager.key(type, receiver_id), FeedManager::MAX_ITEMS - 1, FeedManager::MAX_ITEMS - 1)
    redis.zremrangebyscore(FeedManager.key(type, receiver_id), '-inf', "(#{last.last}")
  end

  def redis
    $redis
  end
end
