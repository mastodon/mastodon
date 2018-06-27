# frozen_string_literal: true
# == Schema Information
#
# Table name: statuses_tags
#
#  status_id :bigint(8)        not null
#  tag_id    :bigint(8)        not null
#

class StatusesTag < ApplicationRecord
  class << self

    def update_trend_tags
      now, level_l, trend_l = get_data
      score, level_now, trend_now = calc_score(level_l, trend_l, now)
      put_data(score, level_now, trend_now)
    end

    private

    def get_data
      unless redis.exists('trend_tags_management_data')
        redis.hset('trend_tags_management_data', 'updated_at', Time.now.utc.iso8601)
      end
      [
        aggregate_tags_in,
        get_previous_data('trend_tags_management_data', 'level_L'),
        get_previous_data('trend_tags_management_data', 'trend_L')
      ]
    end

    def get_previous_data(key, field)
      JSON.parse(redis.hget(key, field).presence || '{}')
    end

    def put_data(score, level, trend)
      previous_score = {
        'updated_at': redis.hget('trend_tags_management_data', 'updated_at'),
        'score': redis.zrevrange('trend_tags', 0, -1, withscores: true).to_h
      }
      list_length = redis.llen('trend_tags_history')
      redis.multi do |r|
        r.rpop('trend_tags_history') if list_length >= 12
        r.lpush('trend_tags_history', previous_score.to_json)
        r.del('trend_tags')
        r.zadd('trend_tags', score) unless score.empty?
        r.hmset('trend_tags_management_data', 'updated_at', Time.now.utc.iso8601, 'level_L', level.to_json, 'trend_L', trend.to_json)
      end
    end

    # Double Exponential Smoothing
    def calc_score(level_l, trend_l, now)
      level_now = {}
      trend_now = {}
      trend_score = []
      tag_keys(level_l, now).each do |k|
        l_l = level_l[k].to_f
        t_l = trend_l[k].to_f
        n = now[k].to_i
        tag = Tag.find(k.to_i)
        sl = score_level(now: n, level_last: l_l, trend_last: t_l)
        st = score_trend(level: sl, level_last: l_l, trend_last: t_l)
        if (sl + st) < 0.5
          next
        end
        level_now[k] = sl.round(3)
        trend_now[k] = st.round(3)
        trend_score << [(sl + st).round(2), tag[:name]]
      end
      [trend_score, level_now, trend_now]
    end

    def tag_keys(*args)
      args.map(&:keys).flatten.uniq
    end

    # for Double Exponential Smoothing
    def score_level(now: 0, level_last: 0.0, trend_last: 0.0, alpha: 0.5)
      alpha * now + (1 - alpha) * (level_last + trend_last)
    end

    # for Double Exponential Smoothing
    def score_trend(level: 0, level_last: 0.0, trend_last: 0.0, gamma: 0.3)
      [gamma * (level - level_last) + (1 - gamma) * trend_last, 0].max # return 0 if trend is negative
    end

    def aggregate_tags_in(t: 10.minutes, until_t: Time.now.utc)
      status_ids = status_ids_in((until_t - t)..until_t)
      StatusesTag.where(status_id: status_ids).group(:tag_id).count.map{|k, v| [k.to_s, v]}.to_h
    end

    def status_ids_in(time_range)
      Status.where(created_at: time_range).local.with_public_or_unlisted_visibility.map(&:id)
    end

    def redis
      Redis.current
    end
  end
end
