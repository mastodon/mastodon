# frozen_string_literal: true

class Feed
  def initialize(type, account)
    @type    = type
    @account = account
  end

  def get(limit, max_id = nil, since_id = nil)
    max_id     = '+inf' if max_id.blank?
    since_id   = '-inf' if since_id.blank?
    unhydrated = redis.zrevrangebyscore(key, "(#{max_id}", "(#{since_id}", limit: [0, limit], with_scores: true).map(&:last).map(&:to_i)

    # If we're after most recent items and none are there, we need to precompute the feed
    if unhydrated.empty? && max_id == '+inf' && since_id == '-inf'
      RegenerationWorker.perform_async(@account.id, @type)
      @statuses = Status.send("as_#{@type}_timeline", @account).paginate_by_max_id(limit, nil, nil)
    else
      status_map = Status.where(id: unhydrated).with_includes.with_counters.map { |status| [status.id, status] }.to_h
      @statuses = unhydrated.map { |id| status_map[id] }.compact
    end

    @statuses
  end

  private

  def key
    FeedManager.instance.key(@type, @account.id)
  end

  def redis
    Redis.current
  end
end
