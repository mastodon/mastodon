# frozen_string_literal: true

class Api::V1::Timelines::LinkController < Api::V1::Timelines::BaseController
  before_action -> { authorize_if_got_token! :read, :'read:statuses' }
  before_action :set_preview_card
  before_action :set_statuses

  PERMITTED_PARAMS = %i(
    url
    limit
  ).freeze

  def show
    cache_if_unauthenticated!
    render json: @statuses, each_serializer: REST::StatusSerializer, relationships: StatusRelationshipsPresenter.new(@statuses, current_user&.account_id)
  end

  private

  def set_preview_card
    @preview_card = PreviewCard.joins(:trend).merge(PreviewCardTrend.allowed).find_by!(url: params[:url])
  end

  def set_statuses
    @statuses = @preview_card.nil? ? [] : preload_collection(link_timeline_statuses, Status)
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

  def next_path
    api_v1_timelines_link_url next_path_params
  end

  def prev_path
    api_v1_timelines_link_url prev_path_params
  end
end
