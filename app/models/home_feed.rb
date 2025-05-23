# frozen_string_literal: true

class HomeFeed < Feed
  def initialize(account)
    @account = account
    super(:home, account.id)
  end

  def regenerating?
    redis.exists?("account:#{@account.id}:regeneration")
  end

  def get(limit, max_id = nil, since_id = nil, min_id = nil)
    limit    = limit.to_i
    max_id   = max_id.to_i if max_id.present?
    since_id = since_id.to_i if since_id.present?
    min_id   = min_id.to_i if min_id.present?

    from_redis(limit, max_id, since_id, min_id)
  end

  def from_redis(limit, max_id, since_id, min_id)
    # Resolve max_id, since_id, and min_id to their corresponding scores
    max_score = max_id.present? ? redis.zscore(key, max_id) || '+inf' : '+inf'
    since_score = since_id.present? ? redis.zscore(key, since_id) || '-inf' : '-inf'
    min_score = min_id.present? ? redis.zscore(key, min_id) || '-inf' : nil

    # Fetch unhydrated keys and their scores based on resolved scores
    if min_score.nil?
      hydrated_with_scores = redis.zrevrangebyscore(key, "(#{max_score}", "(#{since_score}", limit: [0, limit], with_scores: true)
    else
      hydrated_with_scores = redis.zrangebyscore(key, "(#{min_score}", "(#{max_score}", limit: [0, limit], with_scores: true)
    end

    # Map unhydrated keys and their scores
    u_map = hydrated_with_scores.to_h { |key, score| [key.to_i, score.to_f] }

    # Map unhydrated keys and sort them by scores in descending order
    Status.where(id: u_map.keys).cache_ids.sort_by { |status| -u_map[status.id.to_s].to_f }
  end
end