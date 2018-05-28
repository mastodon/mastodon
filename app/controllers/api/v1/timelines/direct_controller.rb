# frozen_string_literal: true

class Api::V1::Timelines::DirectController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read }, only: [:show]
  before_action :require_user!, only: [:show]
  after_action :insert_pagination_headers, unless: -> { @statuses.empty? }

  respond_to :json

  def show
    @statuses = load_statuses
    render json: @statuses, each_serializer: REST::StatusSerializer, relationships: StatusRelationshipsPresenter.new(@statuses, current_user&.account_id)
  end

  private

  def load_statuses
    cached_direct_statuses
  end

  def cached_direct_statuses
    cache_collection direct_statuses, Status
  end

  def direct_statuses
    direct_timeline_statuses
  end

  def direct_timeline_statuses
    # this query requires built in pagination.
    Status.as_direct_timeline(
      current_account,
      limit_param(DEFAULT_STATUSES_LIMIT),
      params[:max_id],
      params[:since_id],
      true # returns array of cache_ids object
    )
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def pagination_params(core_params)
    params.permit(:local, :limit).merge(core_params)
  end

  def next_path
    api_v1_timelines_direct_url pagination_params(max_id: pagination_max_id)
  end

  def prev_path
    api_v1_timelines_direct_url pagination_params(since_id: pagination_since_id)
  end

  def pagination_max_id
    @statuses.last.id
  end

  def pagination_since_id
    @statuses.first.id
  end
end
