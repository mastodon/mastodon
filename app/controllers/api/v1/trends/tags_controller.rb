# frozen_string_literal: true

class Api::V1::Trends::TagsController < Api::BaseController
  before_action :set_tags

  after_action :insert_pagination_headers

  DEFAULT_TAGS_LIMIT = (ENV['MAX_TRENDING_TAGS'] || 10).to_i

  def index
    render json: @tags, each_serializer: REST::TagSerializer, relationships: TagRelationshipsPresenter.new(@tags, current_user&.account_id)
  end

  private

  def enabled?
    Setting.trends
  end

  def set_tags
    @tags = if enabled?
              tags_from_trends.offset(offset_param).limit(limit_param(DEFAULT_TAGS_LIMIT))
            else
              []
            end
  end

  def tags_from_trends
    Trends.tags.query.allowed
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def pagination_params(core_params)
    params.slice(:limit).permit(:limit).merge(core_params)
  end

  def next_path
    api_v1_trends_tags_url pagination_params(offset: offset_param + limit_param(DEFAULT_TAGS_LIMIT)) if records_continue?
  end

  def prev_path
    api_v1_trends_tags_url pagination_params(offset: offset_param - limit_param(DEFAULT_TAGS_LIMIT)) if offset_param > limit_param(DEFAULT_TAGS_LIMIT)
  end

  def offset_param
    params[:offset].to_i
  end

  def records_continue?
    @tags.size == limit_param(DEFAULT_TAGS_LIMIT)
  end
end
