# frozen_string_literal: true

class Api::V1::Trends::TagsController < Api::BaseController
  include DeprecationConcern

  before_action :set_tags

  after_action :insert_pagination_headers

  DEFAULT_TAGS_LIMIT = 10

  deprecate_api '2022-03-30', only: :index, if: -> { request.path == '/api/v1/trends' }

  def index
    cache_if_unauthenticated!
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
    scope = Trends.tags.query.allowed.in_locale(content_locale)
    scope = scope.filtered_for(current_account) if user_signed_in?
    scope
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
