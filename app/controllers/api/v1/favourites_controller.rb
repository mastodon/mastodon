# frozen_string_literal: true

class Api::V1::FavouritesController < ApiController
  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!

  respond_to :json

  def index
    results   = Favourite.where(account: current_account).paginate_by_max_id(limit_param(DEFAULT_STATUSES_LIMIT), params[:max_id], params[:since_id])
    @statuses = cache_collection(Status.where(id: results.map(&:status_id)), Status)

    set_maps(@statuses)
    # set_counters_maps(@statuses)

    next_path = api_v1_favourites_url(max_id: results.last.id)    if results.size == limit_param(DEFAULT_STATUSES_LIMIT)
    prev_path = api_v1_favourites_url(since_id: results.first.id) unless results.empty?

    set_pagination_headers(next_path, prev_path)
  end
end
