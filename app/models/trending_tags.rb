# frozen_string_literal: true

class TrendingTags
  KEY                  = 'trending_tags'
  EXPIRE_HISTORY_AFTER = 7.days.seconds
  EXPIRE_TRENDS_AFTER  = 1.day.seconds
  THRESHOLD            = 5

  class << self
    include Redisable

    def record_use!(tag, account, at_time = Time.now.utc)
      return if account.silenced? || account.bot? || !tag.usable? || !(tag.trendable? || tag.requires_review?)

      increment_historical_use!(tag.id, at_time)
      increment_unique_use!(tag.id, account.id, at_time)
      increment_vote!(tag, at_time)
    end

    def get(limit, filtered: true)
      tag_ids = redis.zrevrange("#{KEY}:#{Time.now.utc.beginning_of_day.to_i}", 0, limit - 1).map(&:to_i)

      tags = Tag.where(id: tag_ids)
      tags = tags.where(trendable: true) if filtered
      tags = tags.each_with_object({}) { |tag, h| h[tag.id] = tag }

      tag_ids.map { |tag_id| tags[tag_id] }.compact
    end

    def trending?(tag)
      rank = redis.zrevrank("#{KEY}:#{Time.now.utc.beginning_of_day.to_i}", tag.id)
      rank.present? && rank <= 10
    end

    private

    def increment_historical_use!(tag_id, at_time)
      key = "activity:tags:#{tag_id}:#{at_time.beginning_of_day.to_i}"
      redis.incrby(key, 1)
      redis.expire(key, EXPIRE_HISTORY_AFTER)
    end

    def increment_unique_use!(tag_id, account_id, at_time)
      key = "activity:tags:#{tag_id}:#{at_time.beginning_of_day.to_i}:accounts"
      redis.pfadd(key, account_id)
      redis.expire(key, EXPIRE_HISTORY_AFTER)
    end

    def increment_vote!(tag, at_time)
      key      = "#{KEY}:#{at_time.beginning_of_day.to_i}"
      expected = redis.pfcount("activity:tags:#{tag.id}:#{(at_time - 1.day).beginning_of_day.to_i}:accounts").to_f
      expected = 1.0 if expected.zero?
      observed = redis.pfcount("activity:tags:#{tag.id}:#{at_time.beginning_of_day.to_i}:accounts").to_f

      if expected > observed || observed < THRESHOLD
        redis.zrem(key, tag.id)
      else
        score    = ((observed - expected)**2) / expected
        old_rank = redis.zrevrank(key, tag.id)

        redis.zadd(key, score, tag.id)
        request_review!(tag) if (old_rank.nil? || old_rank > 10) && redis.zrevrank(key, tag.id) <= 10 && !tag.trendable? && tag.requires_review? && !tag.requested_review?
      end

      redis.expire(key, EXPIRE_TRENDS_AFTER)
    end

    def request_review!(tag)
      User.staff.includes(:account).find_each { |u| AdminMailer.new_trending_tag(u.account, tag).deliver_later! if u.allows_trending_tag_emails? }
    end
  end
end
