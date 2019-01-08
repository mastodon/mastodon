# frozen_string_literal: true

class Api::V1::SearchController < Api::BaseController
  include Authorization

  RESULTS_LIMIT = 5

  before_action -> { doorkeeper_authorize! :read, :'read:search' }
  before_action :require_user!

  respond_to :json

  def index
    @search = Search.new(search)
    render json: @search, serializer: REST::SearchSerializer
  end

  private

  def search
    search_results.tap do |search|
      search[:statuses].keep_if do |status|
        begin
          authorize status, :show?
        rescue Mastodon::NotPermittedError
          false
        end
      end
    end
  end

  def search_results
    SearchService.new.call(
      params[:q],
      RESULTS_LIMIT,
      truthy_param?(:resolve),
      current_account
    )
  end
end
