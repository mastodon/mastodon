# frozen_string_literal: true

class Api::V1::TrendTagsController < Api::BaseController
  respond_to :json

  def show
    render json: trend_score
  end

  private

  def trend_score
    if history_mode?
      redis.lrange('trend_tags_history', 0, -1).map { |item| JSON.parse(item) }
    else
      {
        'updated_at' => redis.hget('trend_tags_management_data', 'updated_at'),
        'score' => redis.zrevrange('trend_tags', 0, -1, withscores: true).to_h,
      }
    end
  end

  def history_mode?
    ActiveModel::Type::Boolean.new.cast(trend_tags_params[:history_mode]) 
  end

  def trend_tags_params
    params.permit(:history_mode)
  end

  def redis
    Redis.current
  end
end
