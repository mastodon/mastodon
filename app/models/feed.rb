class Feed
  def initialize(type, account)
    @type    = type
    @account = account
  end

  def get(limit, max_id = nil, since_id = nil)
    max_id     = '+inf' if max_id.blank?
    since_id   = '-inf' if since_id.blank?
    unhydrated = redis.zrevrangebyscore(key, "(#{max_id}", "(#{since_id}", limit: [0, limit], with_scores: true).collect(&:last).map(&:to_i)

    # If we're after most recent items and none are there, we need to precompute the feed
    if unhydrated.empty? && max_id == '+inf' && since_id == '-inf'
      PrecomputeFeedService.new.call(@type, @account, limit)
    else
      status_map = Status.where(id: unhydrated).with_includes.with_counters.map { |status| [status.id, status] }.to_h
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
