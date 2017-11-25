# frozen_string_literal: true
# == Schema Information
#
# Table name: statuses_tags
#
#  status_id :integer          not null
#  tag_id    :integer          not null
#

class StatusesTag < ApplicationRecord
  class << self
    def calc_trend
      unless redis.exists('trend_tag')
        redis.hset('trend_tag', 'updated_at', Time.now.utc.iso8601)
      end
      level_l = JSON.parse(redis.hget('trend_tag', 'level_L').presence || '{}')
      trend_l = JSON.parse(redis.hget('trend_tag', 'trend_L').presence || '{}')
      now = aggregate_tags_in

      score, level_now, trend_now = calc_score(level_l, trend_l, now)
      redis.hmset('trend_tag', 'updated_at', Time.now.utc.iso8601, 'score', score.to_json, 'level_L', level_now.to_json, 'trend_L', trend_now.to_json)
    end

    private

    # Double Exponential Smoothing
    def calc_score(level_l, trend_l, now)
      level_now = {}
      trend_now = {}
      trend_score = {}
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
        trend_score[tag[:name]] = (sl + st).round(2)
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
      Status.where(created_at: time_range, local: true).map(&:id)
    end

    def redis
      Redis.current
    end
  end
end
