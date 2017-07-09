# frozen_string_literal: true

class Api::V1::SearchController < Api::BaseController
  RESULTS_LIMIT = 5

  respond_to :json

  def index
    @search = OpenStruct.new(search_results)
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
