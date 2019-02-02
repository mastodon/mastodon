# frozen_string_literal: true

class Api::V1::FavouritesController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:favourites' }
  before_action :require_user!
  after_action :insert_pagination_headers

  respond_to :json

  def index
    @statuses = load_statuses
    render json: @statuses, each_serializer: REST::StatusSerializer, relationships: StatusRelationshipsPresenter.new(@statuses, current_user&.account_id)
  end

  private

  def load_statuses
    cached_favourites
  end

  def cached_favourites
    cache_collection(
      Status.reorder(nil).joins(:favourites).merge(results),
      Status
    )
  end

  def results
    @_results ||= account_favourites.paginate_by_id(
      limit_param(DEFAULT_STATUSES_LIMIT),
      params_slice(:max_id, :since_id, :min_id)
    )
  end

  def account_favourites
    current_account.favourites
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def next_path
    if records_continue?
      api_v1_favourites_url pagination_params(max_id: pagination_max_id)
    end
  end

  def prev_path
    unless results.empty?
      api_v1_favourites_url pagination_params(min_id: pagination_since_id)
    end
  end

  def pagination_max_id
    results.last.id
  end

  def pagination_since_id
    results.first.id
  end

  def records_continue?
    results.size == limit_param(DEFAULT_STATUSES_LIMIT)
  end

  def pagination_params(core_params)
    params.slice(:limit).permit(:limit).merge(core_params)
  end
end
