# frozen_string_literal: true

class Api::V1::Trends::LinksController < Api::V1::Trends::BaseController
  vary_by 'Authorization, Accept-Language'

  before_action :set_links

  DEFAULT_RECORDS_LIMIT = 10

  def index
    cache_if_unauthenticated!
    render json: @links, each_serializer: REST::Trends::LinkSerializer
  end

  private

  def set_links
    @links = record_collection_when_trends_enabled
  end

  def offset_and_limited_collection
    links_from_trends
      .offset(offset_param)
      .limit(default_records_limit_param)
  end

  def links_from_trends
    scope = Trends.links.query.allowed.in_locale(content_locale)
    scope = scope.filtered_for(current_account) if user_signed_in?
    scope
  end

  def next_path
    api_v1_trends_links_url next_path_params if records_continue?
  end

  def prev_path
    api_v1_trends_links_url prev_path_params if records_precede?
  end

  def records_continue?
    @links.size == default_records_limit_param
  end
end
