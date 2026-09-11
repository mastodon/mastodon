# frozen_string_literal: true

class Feed
  include Redisable

  def initialize(type, id, options = {})
    @type = type
    @id = id
    @options = options
  end

  def get(limit, max_id = nil, since_id = nil, min_id = nil)
    limit    = limit.to_i
    max_id   = max_id.to_i if max_id.present?
    since_id = since_id.to_i if since_id.present?
    min_id   = min_id.to_i if min_id.present?

    from_redis(limit, max_id, since_id, min_id)
  end

  protected

  def from_redis(limit, max_id, since_id, min_id)
    scope = Status.all

    # Apply specified filters
    scope.merge!(Status.where.not(visibility: :direct)) if @options[:exclude_direct]
    scope.merge!(Status.where(reblog_of_id: nil)) if @options[:exclude_reblogs]
    scope.merge!(Status.where(quote_id: nil)) if @options[:exclude_quotes]
    scope.merge!(Status.where(in_reply_to_id: nil).or(Status.where(@id))) if @options[:exclude_replies] # TODO: beware

    # If we have no filter, rely on Redis to apply the limit, otherwise we will have to do a posteriori filtering
    limit_clause = [0, limit] if scope == Status.all

    max_id = '+inf' if max_id.blank?
    if min_id.blank?
      since_id   = '-inf' if since_id.blank?
      ids = redis.zrevrangebyscore(key, "(#{max_id}", "(#{since_id}", limit: limit_clause, with_scores: true).map { |id| id.first.to_i }
    else
      ids = redis.zrangebyscore(key, "(#{min_id}", "(#{max_id}", limit: limit_clause, with_scores: true).map { |id| id.first.to_i }
    end

    if min_id.blank? || limit_clause.present?
      scope.where(id: ids).limit(limit)
    else
      # We need to do some filtering *and* do it in the correct order
      Status.where(id: scope.reorder(id: :asc).where(id: ids).limit(limit))
    end
  end

  def key
    FeedManager.instance.key(@type, @id)
  end
end
