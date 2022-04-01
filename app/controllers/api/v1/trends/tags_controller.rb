# frozen_string_literal: true

class Api::V1::Trends::TagsController < Api::BaseController
  before_action :set_tags

  after_action :insert_pagination_headers

  DEFAULT_TAGS_LIMIT = 10

  def index
    render json: @tags, each_serializer: REST::TagSerializer
  end

  private

  def set_tags
    @tags = begin
      if Setting.trends
        Trends.tags.query.allowed.limit(limit_param(DEFAULT_TAGS_LIMIT))
      else
        []
      end
    end
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def pagination_params(core_params)
    params.slice(:limit).permit(:limit).merge(core_params)
  end

  def next_path
    api_v1_trends_tags_url pagination_params(offset: offset_param + limit_param(DEFAULT_TAGS_LIMIT))
  end

  def prev_path
    api_v1_trends_tags_url pagination_params(offset: offset_param - limit_param(DEFAULT_TAGS_LIMIT)) if offset_param > limit_param(DEFAULT_TAGS_LIMIT)
  end

  def offset_param
    params[:offset].to_i
  end
end
