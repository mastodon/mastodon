class Feed
  def initialize(type, account)
    @type    = type
    @account = account
  end

  def get(limit, max_id = '+inf')
    unhydrated = redis.zrevrangebyscore(key, "(#{max_id}", '-inf', limit: [0, limit])
    status_map = Hash.new

    # If we're after most recent items and none are there, we need to precompute the feed
    return PrecomputeFeedService.new.(@type, @account).take(limit) if unhydrated.empty? && max_id == '+inf'

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
