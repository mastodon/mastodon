# frozen_string_literal: true

class Api::V1::Timelines::TagController < Api::BaseController
  before_action :load_tag
  after_action :insert_pagination_headers, unless: -> { @statuses.empty? }

  def show
    @statuses = load_statuses
    render json: @statuses, each_serializer: REST::StatusSerializer, relationships: StatusRelationshipsPresenter.new(@statuses, current_user&.account_id)
  end

  private

  def load_tag
    @tag = Tag.find_normalized(params[:id])
  end

  def load_statuses
    cached_tagged_statuses
  end

  def cached_tagged_statuses
    @tag.nil? ? [] : cache_collection(tag_timeline_statuses, Status)
  end

  def tag_timeline_statuses
    tag_feed.get(
      limit_param(DEFAULT_STATUSES_LIMIT),
      params[:max_id],
      params[:since_id],
      params[:min_id]
    )
  end

  def tag_feed
    TagFeed.new(
      @tag,
      current_account,
      any: params[:any],
      all: params[:all],
      none: params[:none],
      local: truthy_param?(:local),
      remote: truthy_param?(:remote),
      only_media: truthy_param?(:only_media)
    )
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def pagination_params(core_params)
    params.slice(:local, :limit, :only_media).permit(:local, :limit, :only_media).merge(core_params)
  end

  def next_path
    api_v1_timelines_tag_url params[:id], pagination_params(max_id: pagination_max_id)
  end

  def prev_path
    api_v1_timelines_tag_url params[:id], pagination_params(min_id: pagination_since_id)
  end

  def pagination_max_id
    @statuses.last.id
  end

  def pagination_since_id
    @statuses.first.id
  end
end
