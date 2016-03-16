class Feed
  def initialize(type, account)
    @type    = type
    @account = account
  end

  def get(limit, offset = 0)
    unhydrated = redis.zrevrange(key, offset, limit)
    status_map = Hash.new

    # If we're after most recent items and none are there, we need to precompute the feed
    return PrecomputeFeedService.new.(@type, @account).take(limit) if unhydrated.empty? && offset == 0

    Status.where(id: unhydrated).with_includes.with_counters.each { |status| status_map[status.id.to_s] = status }
    return unhydrated.map { |id| status_map[id] }.compact
  end

  private

  def key
    "feed:#{@type}:#{@account.id}"
  end

  def redis
    $redis
  end
end
