class PrecomputeFeedService < BaseService
  MAX_FEED_SIZE = 800

  # Fill up a user's home/mentions feed from DB and return it
  # @param [Symbol] type :home or :mentions
  # @param [Account] account
  # @return [Array]
  def call(type, account)
    statuses = send(type.to_s, account).order('created_at desc').limit(MAX_FEED_SIZE)
    statuses.each { |status| push(type, account.id, status) }
    statuses
  end

  private

  def push(type, receiver_id, status)
    redis.zadd(key(type, receiver_id), status.id, status.id)
  end

  def home(account)
    Status.where(account: [account] + account.following).with_includes.with_counters
  end

  def mentions(account)
    Status.where(id: Mention.where(account: account).pluck(:status_id)).with_includes.with_counters
  end

  def key(type, id)
    "feed:#{type}:#{id}"
  end

  def redis
    $redis
  end
end
