# to do: modify this to fix pagination
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

    Rails.logger.info "home_feed.rb get: key=#{key}, limit=#{limit}, max_id=#{max_id}, since_id=#{since_id}, min_id=#{min_id}"

    from_redis(limit, max_id, since_id, min_id)
  end

  # def from_redis_withscores(limit, max_id, since_id, min_id)
  #   if min_id == '-inf'
  #     unhydrated_with_scores = redis.zrevrangebyscore(key, "(#{max_id}", "(#{since_id}", limit: [0, limit], with_scores: true)
  #   else
  #     unhydrated_with_scores = redis.zrangebyscore(key, "(#{min_id}", "(#{max_id}", limit: [0, limit], with_scores: true)
  #   end
  
  #   # Create a map of ID to score
  #   score_map = unhydrated_with_scores.to_h
  
  #   # Fetch statuses and include scores
  #   Status.where(id: score_map.keys.map(&:to_i)).cache_ids.map do |status|
  #     status.define_singleton_method(:score) { score_map[status.id.to_s] }
  #     status
  #   end.sort_by { |status| -status.score }
  # end
  

  def from_redis(limit, max_id, since_id, min_id)
    Rails.logger.info "home_feed.rb from_redis START: key=#{key}, limit=#{limit}, max_id=#{max_id}, since_id=#{since_id}, min_id=#{min_id}"
  
    # Resolve max_id, since_id, and min_id to their corresponding scores
    max_score = max_id.present? ? redis.zscore(key, max_id) || '+inf' : '+inf'
    Rails.logger.info "home_feed.rb Resolved max_score=#{max_score} for max_id=#{max_id}"
  
    since_score = since_id.present? ? redis.zscore(key, since_id) || '-inf' : '-inf'
    Rails.logger.info "home_feed.rb Resolved since_score=#{since_score} for since_id=#{since_id}"
  
    min_score = min_id.present? ? redis.zscore(key, min_id) || '-inf' : nil
    Rails.logger.info "home_feed.rb Resolved min_score=#{min_score} for min_id=#{min_id}"
  
    # Fetch unhydrated keys and their scores based on resolved scores
    if min_score.nil?
      Rails.logger.info "home_feed.rb Fetching scores using zrevrangebyscore with max_score=#{max_score} and since_score=#{since_score}, limit=#{limit}"
      hydrated_with_scores = redis.zrevrangebyscore(key, "(#{max_score}", "(#{since_score}", limit: [0, limit], with_scores: true)
    else
      Rails.logger.info "home_feed.rb Fetching scores using zrangebyscore with min_score=#{min_score} and max_score=#{max_score}, limit=#{limit}"
      hydrated_with_scores = redis.zrangebyscore(key, "(#{min_score}", "(#{max_score}", limit: [0, limit], with_scores: true)
    end
  
    Rails.logger.info "home_feed.rb Fetched hydrated_with_scores: #{hydrated_with_scores.inspect}"
  
    # Map unhydrated keys and their scores
    u_map = hydrated_with_scores.to_h { |key, score| [key.to_i, score.to_f] }
    Rails.logger.info "home_feed.rb Mapped u_map: #{u_map.inspect}"
  
    # Additional processing or return statement here
    Rails.logger.info "home_feed.rb home_feed.rb from_redis END"
  
    # Map unhydrated keys and sort them by scores in descending order
    Status.where(id: u_map.keys).cache_ids.sort_by { |status| -u_map[status.id.to_s].to_f }
  end
end
