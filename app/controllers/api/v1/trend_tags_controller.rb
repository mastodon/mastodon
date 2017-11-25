# frozen_string_literal: true

class Api::V1::TrendTagsController < Api::BaseController
  respond_to :json

  def show
    trend_score = {
      'updated_at' => redis.hget('trend_tag', 'updated_at'),
      'score' => JSON.parse(redis.hget('trend_tag', 'score').presence || '{}'),
    }
    render json: trend_score
  end

  private

  def redis
    Redis.current
  end
end
