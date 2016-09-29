class Feed
  def initialize(type, account)
    @type    = type
    @account = account
  end

  def get(limit, max_id = nil)
    max_id     = '+inf' if max_id.nil?
    unhydrated = redis.zrevrangebyscore(key, "(#{max_id}", '-inf', limit: [0, limit])
    status_map = {}

    # If we're after most recent items and none are there, we need to precompute the feed
    if unhydrated.empty? && max_id == '+inf'
      PrecomputeFeedService.new.call(@type, @account, limit)
    else
      Status.where(id: unhydrated).with_includes.with_counters.each { |status| status_map[status.id.to_s] = status }
      unhydrated.map { |id| status_map[id] }.compact
    end
  end

  private

  def key
    FeedManager.instance.key(@type, @account.id)
  end

  def redis
    $redis
  end
end
