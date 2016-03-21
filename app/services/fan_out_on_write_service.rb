class FanOutOnWriteService < BaseService
  MAX_FEED_SIZE = 800

  # Push a status into home and mentions feeds
  # @param [Status] status
  def call(status)
    deliver_to_self(status) if status.account.local?
    deliver_to_followers(status, status.reply? ? status.thread.account : nil)
    deliver_to_mentioned(status)
  end

  private

  def deliver_to_self(status)
    push(:home, status.account.id, status)
  end

  def deliver_to_followers(status, replied_to_user)
    status.account.followers.each do |follower|
      next if (status.reply? && !(follower.id = replied_to_user.id || follower.following?(replied_to_user))) || !follower.local?
      push(:home, follower.id, status)
    end
  end

  def deliver_to_mentioned(status)
    status.mentioned_accounts.each do |mention|
      mentioned_account = mention.account
      next unless mentioned_account.local?
      push(:mentions, mentioned_account.id, status)
    end
  end

  def push(type, receiver_id, status)
    redis.zadd(key(type, receiver_id), status.created_at.to_i, status.id)
    trim(type, receiver_id)
  end

  def trim(type, receiver_id)
    return unless redis.zcard(key(type, receiver_id)) > MAX_FEED_SIZE

    last = redis.zrevrange(key(type, receiver_id), MAX_FEED_SIZE - 1, MAX_FEED_SIZE - 1)
    redis.zremrangebyscore(key(type, receiver_id), '-inf', "(#{last.last}")
  end

  def key(type, id)
    "feed:#{type}:#{id}"
  end

  def redis
    $redis
  end
end
