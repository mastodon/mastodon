# frozen_string_literal: true

class TrendingTags
  KEY                  = 'trending_tags'
  EXPIRE_HISTORY_AFTER = 7.days.seconds
  EXPIRE_TRENDS_AFTER  = 1.day.seconds
  THRESHOLD            = 5
  LIMIT                = 10
  REVIEW_THRESHOLD     = 3
  MAX_SCORE_COOLDOWN   = 2.days.freeze
  MAX_SCORE_HALFLIFE   = 2.hours.freeze

  class << self
    include Redisable

    def record_use!(tag, account, status: nil, at_time: Time.now.utc)
      return unless tag.usable? && !account.silenced?

      # Even if a tag is not allowed to trend, we still need to
      # record the stats since they can be displayed in other places
      increment_historical_use!(tag.id, at_time)
      increment_unique_use!(tag.id, account.id, at_time)
      increment_use!(tag.id, at_time)

      # Only update when the tag was last used once every 12 hours
      # and only if a status is given (lets use ignore reblogs)
      tag.update(last_status_at: at_time) if status.present? && (tag.last_status_at.nil? || (tag.last_status_at < at_time && tag.last_status_at < 12.hours.ago))
    end

    def update!(at_time = Time.now.utc)
      tag_ids = redis.smembers("#{KEY}:used:#{at_time.beginning_of_day.to_i}") + redis.zrange(KEY, 0, -1)
      tags    = Tag.where(id: tag_ids.uniq)

      # First pass to calculate scores and update the set

      tags.each do |tag|
        expected  = redis.pfcount("activity:tags:#{tag.id}:#{(at_time - 1.day).beginning_of_day.to_i}:accounts").to_f
        expected  = 1.0 if expected.zero?
        observed  = redis.pfcount("activity:tags:#{tag.id}:#{at_time.beginning_of_day.to_i}:accounts").to_f
        max_time  = tag.max_score_at
        max_score = tag.max_score
        max_score = 0 if max_time.nil? || max_time < (at_time - MAX_SCORE_COOLDOWN)

        score = begin
          if expected > observed || observed < THRESHOLD
            0
          else
            ((observed - expected)**2) / expected
          end
        end

        if score > max_score
          max_score = score
          max_time  = at_time

          # Not interested in triggering any callbacks for this
          tag.update_columns(max_score: max_score, max_score_at: max_time)
        end

        decaying_score = max_score * (0.5**((at_time.to_f - max_time.to_f) / MAX_SCORE_HALFLIFE.to_f))

        if decaying_score.zero?
          redis.zrem(KEY, tag.id)
        else
          redis.zadd(KEY, decaying_score, tag.id)
        end
      end

      users_for_review = User.staff.includes(:account).to_a.select(&:allows_trending_tag_emails?)

      # Second pass to notify about previously unreviewed trends

      tags.each do |tag|
        current_rank              = redis.zrevrank(KEY, tag.id)
        needs_review_notification = tag.requires_review? && !tag.requested_review?
        rank_passes_threshold     = current_rank.present? && current_rank <= REVIEW_THRESHOLD

        next unless !tag.trendable? && rank_passes_threshold && needs_review_notification

        tag.touch(:requested_review_at)

        users_for_review.each do |user|
          AdminMailer.new_trending_tag(user.account, tag).deliver_later!
        end
      end

      # Trim older items

      redis.zremrangebyrank(KEY, 0, -(LIMIT + 1))
      redis.zremrangebyscore(KEY, '(0.3', '-inf')
    end

    def get(limit, filtered: true)
      tag_ids = redis.zrevrange(KEY, 0, LIMIT - 1).map(&:to_i)

      tags = Tag.where(id: tag_ids)
      tags = tags.trendable if filtered
      tags = tags.index_by(&:id)

      tag_ids.map { |tag_id| tags[tag_id] }.compact.take(limit)
    end

    def trending?(tag)
      rank = redis.zrevrank(KEY, tag.id)
      rank.present? && rank < LIMIT
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

    def increment_use!(tag_id, at_time)
      key = "#{KEY}:used:#{at_time.beginning_of_day.to_i}"
      redis.sadd(key, tag_id)
      redis.expire(key, EXPIRE_HISTORY_AFTER)
    end
  end
end
