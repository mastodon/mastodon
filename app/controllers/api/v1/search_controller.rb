# frozen_string_literal: true

class Api::V1::SearchController < Api::BaseController
  RESULTS_LIMIT = 5

  before_action -> { doorkeeper_authorize! :read }
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
      RESULTS_LIMIT,
      resolving_search?,
      current_account
    )
  end

  def resolving_search?
    params[:resolve] == 'true'
  end
end
