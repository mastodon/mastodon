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
      status_map = cache(unhydrated)
      @statuses = unhydrated.map { |id| status_map[id] }.compact
    end

    @statuses
  end

  private

  def cache(ids)
    raw                    = Status.where(id: ids).to_a
    uncached_ids           = []
    cached_keys_with_value = Rails.cache.read_multi(*raw.map(&:cache_key))

    raw.each do |status|
      uncached_ids << status.id unless cached_keys_with_value.key?(status.cache_key)
    end

    unless uncached_ids.empty?
      uncached = Status.where(id: uncached_ids).with_includes.map { |s| [s.id, s] }.to_h

      uncached.values.each do |status|
        Rails.cache.write(status.cache_key, status)
      end
    end

    cached = cached_keys_with_value.values.map { |s| [s.id, s] }.to_h
    cached.merge!(uncached) unless uncached_ids.empty?

    cached
  end

  def key
    FeedManager.instance.key(@type, @account.id)
  end

  def redis
    Redis.current
  end
end
