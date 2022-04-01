# frozen_string_literal: true

class Api::V1::Trends::LinksController < Api::BaseController
  before_action :set_links

  after_action :insert_pagination_headers

  DEFAULT_LINKS_LIMIT = 10

  def index
    render json: @links, each_serializer: REST::Trends::LinkSerializer
  end

  private

  def set_links
    @links = begin
      if Setting.trends
        links_from_trends
      else
        []
      end
    end
  end

  def links_from_trends
    Trends.links.query.allowed.in_locale(content_locale).offset(offset_param).limit(limit_param(DEFAULT_LINKS_LIMIT))
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def pagination_params(core_params)
    params.slice(:limit).permit(:limit).merge(core_params)
  end

  def next_path
    api_v1_trends_links_url pagination_params(offset: offset_param + limit_param(DEFAULT_LINKS_LIMIT))
  end

  def prev_path
    api_v1_trends_links_url pagination_params(offset: offset_param - limit_param(DEFAULT_LINKS_LIMIT)) if offset_param > limit_param(DEFAULT_LINKS_LIMIT)
  end

  def offset_param
    params[:offset].to_i
  end
end
