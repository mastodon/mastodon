# frozen_string_literal: true

class Api::V1::TrendTagsController < Api::BaseController
  respond_to :json

  def show
    trend_score = {
      'updated_at' => redis.hget('trend_tags_management_data', 'updated_at'),
      'score' => redis.zrevrange('trend_tags', 0, -1, withscores: true).to_h,
    }
    render json: trend_score
  end

  private

  def redis
    Redis.current
  end
end
