# frozen_string_literal: true
# == Schema Information
#
# Table name: statuses_tags
#
#  status_id  :integer          not null, primary key
#  tag_id     :integer          not null
#

class StatusesTag < ApplicationRecord
  class << self
    def calc_trend
      unless redis.exists('trend_tag')
        redis.hset('trend_tag', 'updated_at', Time.now.utc.iso8601)
      end
      before = JSON.parse(redis.hget('trend_tag', 'before').presence || '{}')
      last = JSON.parse(redis.hget('trend_tag', 'last').presence || '{}')
      now = JSON.parse(aggregate_tags_in.to_json)

      score = calc_score(before, last, now)
      redis.hmset('trend_tag', 'updated_at', Time.now.utc.iso8601, 'score', score.to_json, 'last', now.to_json, 'before', last.to_json)

      score_ex, level_l, trend_l = calc_score_experimental(before, last, now)
      redis.hmset('trend_tag', 'score_ex', score_ex.to_json, 'level_L', level_l.to_json, 'trend_L', trend_l.to_json)
    end

    private

    def calc_score(before, last, now)
      trend_score = {}
      tag_keys(before, last, now).each do |k|
        b = before[k].to_i # to_i converts nil to 0
        l = last[k].to_i
        n = now[k].to_i
        tag = Tag.find(k.to_i)
        trend_score[tag[:name]] = score(now: n, last: l, before: b)
      end
      trend_score
    end

    # Double Exponential Smoothing (experimental)
    def calc_score_experimental(before, last, now)
      level_l = JSON.parse(redis.hget('trend_tag', 'level_L').presence || '{}')
      trend_l = JSON.parse(redis.hget('trend_tag', 'trend_L').presence || '{}')
      level_now = {}
      trend_now = {}
      trend_score_des = {}
      tag_keys(before, last, now).each do |k|
        l_l = level_l[k].to_f
        t_l = trend_l[k].to_f
        n = now[k].to_i
        tag = Tag.find(k.to_i)
        sl = score_level(now: n, level_last: l_l, trend_last: t_l)
        st = score_trend(level: sl, level_last: l_l, trend_last: t_l)
        level_now[k] = sl.round(3)
        trend_now[k] = st.round(3)
        trend_score_des[tag[:name]] = (sl + st).round(3)
      end
      [trend_score_des, level_now, trend_now]
    end

    def tag_keys(*args)
      args.map(&:keys).flatten.uniq
    end

    def score(now: 0, last: 0, before: 0)
      now + (now - last) + (last * 3 / 4.0) + ((last - before) / 2.0) + (before / 4.0)
    end

    # for Double Exponential Smoothing (experimental)
    def score_level(now: 0, level_last: 0.0, trend_last: 0.0, alpha: 0.8)
      alpha * now + (1 - alpha) * (level_last + trend_last)
    end

    # for Double Exponential Smoothing (experimental)
    def score_trend(level: 0, level_last: 0.0, trend_last: 0.0, gamma: 0.3)
      gamma * (level - level_last) + (1 - gamma) * trend_last
    end

    def aggregate_tags_in(t: 10.minutes, until_t: Time.now.utc)
      status_ids = status_ids_in((until_t - t)..until_t)
      StatusesTag.where(status_id: status_ids).group(:tag_id).count
    end

    def status_ids_in(time_range)
      Status.where(created_at: time_range, local: true).map(&:id)
    end

    def redis
      Redis.current
    end
  end
end
