# frozen_string_literal: true

class Api::V2::SearchController < Api::BaseController
  include Authorization

  RESULTS_LIMIT = 20

  before_action -> { doorkeeper_authorize! :read, :'read:search' }
  before_action :require_user!

  def index
    @search = Search.new(search_results)
    render json: @search, serializer: REST::SearchSerializer
  end

  private

  def search_results
    unless params[:account_id]
      by_regex = /\bby:(\w+)(?:@(\S+))?\b/
      query = params[:q]

      query.match(by_regex) do |m|
        params[:q] = query.delete(m.to_s)
        by = m.captures
        params[:account_id] = Account.find_remote(by[0], by[1])&.id
      end
    end

    SearchService.new.call(
      params[:q],
      current_account,
      limit_param(RESULTS_LIMIT),
      search_params.merge(resolve: truthy_param?(:resolve), exclude_unreviewed: truthy_param?(:exclude_unreviewed))
    )
  end

  def search_params
    params.permit(:type, :offset, :min_id, :max_id, :account_id)
  end
end
