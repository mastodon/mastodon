# frozen_string_literal: true

class Api::V1::Timelines::LinkController < Api::BaseController
  before_action :set_preview_card
  before_action :set_statuses

  after_action :insert_pagination_headers, unless: -> { @statuses.empty? }

  def show
    cache_if_unauthenticated!
    render json: @statuses, each_serializer: REST::StatusSerializer, relationships: StatusRelationshipsPresenter.new(@statuses, current_user&.account_id)
  end

  private

  def set_preview_card
    @preview_card = PreviewCard.joins(:trend).merge(PreviewCardTrend.allowed).find_by!(url: params[:url])
  end

  def set_statuses
    @statuses = @preview_card.nil? ? [] : cache_collection(link_timeline_statuses, Status)
  end

  def link_timeline_statuses
    link_feed.get(
      limit_param(DEFAULT_STATUSES_LIMIT),
      params[:max_id],
      params[:since_id],
      params[:min_id]
    )
  end

  def link_feed
    LinkFeed.new(@preview_card, current_account)
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def pagination_params(core_params)
    params.slice(:local, :limit, :only_media).permit(:local, :limit, :only_media).merge(core_params)
  end

  def next_path
    api_v1_timelines_link_url params[:id], pagination_params(max_id: pagination_max_id)
  end

  def prev_path
    api_v1_timelines_link_url params[:id], pagination_params(min_id: pagination_since_id)
  end

  def pagination_max_id
    @statuses.last.id
  end

  def pagination_since_id
    @statuses.first.id
  end
end
