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
      trend_score = {}
      tag_keys(before, last, now).each do |k|
        b = before[k].to_i # to_i converts nil to 0
        l = last[k].to_i
        n = now[k].to_i
        tag = Tag.find(k.to_i)
        trend_score[tag[:name]] = score(now: n, last: l, before: b)
      end
      redis.hmset('trend_tag', 'updated_at', Time.now.utc.iso8601, 'score', trend_score.to_json, 'last', now.to_json, 'before', last.to_json)
    end

    private

    def tag_keys(*args)
      args.map(&:keys).flatten.uniq
    end

    def score(now: 0, last: 0, before: 0)
      now + (now - last) + (last * 3 / 4.0) + ((last - before) / 2.0) + (before / 4.0)
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
