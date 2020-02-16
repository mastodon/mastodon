# frozen_string_literal: true

class Api::V2::SearchController < Api::BaseController
  include Authorization

  RESULTS_LIMIT = 20

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
      filtered_params[:q],
      current_account,
      limit_param(RESULTS_LIMIT),
      search_params.merge(resolve: truthy_param?(:resolve), exclude_unreviewed: truthy_param?(:exclude_unreviewed))
    )
  end

  def filtered_params
    params.require(:q).permit(:type, :offset, :min_id, :max_id, :account_id)
  end

  def search_params
    filtered_params.slice(:type, :offset, :min_id, :max_id, :account_id)
  end
end
