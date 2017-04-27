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
    status_map = Status.where(id: unhydrated).cache_ids.map { |s| [s.id, s] }.to_h

    unhydrated.map { |id| status_map[id] }.compact
  end

  private

  def key
    FeedManager.instance.key(@type, @account.id)
  end

  def redis
    Redis.current
  end
end
