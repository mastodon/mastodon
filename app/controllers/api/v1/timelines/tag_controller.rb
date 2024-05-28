# frozen_string_literal: true

class Api::V1::Timelines::TagController < Api::V1::Timelines::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:statuses' }, only: :show, if: :require_auth?
  before_action :load_tag

  PERMITTED_PARAMS = %i(local limit only_media).freeze

  def show
    cache_if_unauthenticated!
    @statuses = load_statuses
    render json: @statuses, each_serializer: REST::StatusSerializer, relationships: StatusRelationshipsPresenter.new(@statuses, current_user&.account_id)
  end

  private

  def require_auth?
    !Setting.timeline_preview
  end

  def load_tag
    @tag = Tag.find_normalized(params[:id])
  end

  def load_statuses
    preloaded_tagged_statuses
  end

  def preloaded_tagged_statuses
    @tag.nil? ? [] : preload_collection(tag_timeline_statuses, Status)
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

  def next_path
    api_v1_timelines_tag_url params[:id], next_path_params
  end

  def prev_path
    api_v1_timelines_tag_url params[:id], prev_path_params
  end
end
