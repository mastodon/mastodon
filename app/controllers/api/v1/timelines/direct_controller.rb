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
    a1 = cache_collection direct_statuses_from_me, Status
    a2 = cache_collection direct_statuses_to_me, Status
    (a1 + a2).uniq(&:id).sort_by(&:id).reverse.take(limit_param(DEFAULT_STATUSES_LIMIT))
  end

  def direct_statuses_from_me
    direct_timeline_statuses_from_me.paginate_by_max_id(
      limit_param(DEFAULT_STATUSES_LIMIT),
      params[:max_id],
      params[:since_id]
    )
  end

  def direct_statuses_to_me
    # pagenation to mentions.status_id instead of statuses.id
    max_id = params[:max_id]
    since_id = params[:since_id]
    query = direct_timeline_statuses_to_me.order('mentions.status_id desc').limit(limit_param(DEFAULT_STATUSES_LIMIT))
    query = query.where('mentions.status_id < ?', max_id) if max_id.present?
    query = query.where('mentions.status_id > ?', since_id) if since_id.present?
    query
  end

  def direct_timeline_statuses_from_me
    Status.as_direct_timeline_from_me(current_account)
  end

  def direct_timeline_statuses_to_me
    Status.as_direct_timeline_to_me(current_account)
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
