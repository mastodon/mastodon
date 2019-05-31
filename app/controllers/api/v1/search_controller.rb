# frozen_string_literal: true

class Api::V1::SearchController < Api::BaseController
  include Authorization

  RESULTS_LIMIT = (ENV['MAX_SEARCH_RESULTS'] || 20).to_i

  before_action -> { doorkeeper_authorize! :read, :'read:search' }
  before_action :require_user!

  respond_to :json

  def index
    @search = Search.new(search_results)
    render json: @search, serializer: REST::SearchSerializer
  end

  private

  def search_results
    SearchService.new.call(
      params[:q],
      current_account,
      limit_param(RESULTS_LIMIT),
      search_params.merge(resolve: truthy_param?(:resolve))
    )
  end

  def search_params
    params.permit(:type, :offset, :min_id, :max_id, :account_id)
  end
end
