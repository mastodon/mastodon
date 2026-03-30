# frozen_string_literal: true

class Api::V2::SearchController < Api::BaseController
  include AsyncRefreshesConcern
  include Authorization

  RESULTS_LIMIT = 20

  before_action -> { authorize_if_got_token! :read, :'read:search' }
  before_action :validate_search_params!

  with_options unless: :user_signed_in? do
    before_action :query_pagination_error, if: :pagination_requested?
    before_action :remote_resolve_error, if: :remote_resolve_requested?
  end
  before_action :require_valid_pagination_options!
  before_action :handle_fasp_requests

  def index
    @search = Search.new(search_results)
    render json: @search, serializer: REST::SearchSerializer
  rescue Mastodon::SyntaxError
    unprocessable_content
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  private

  def validate_search_params!
    params.require(:q)
  end

  def query_pagination_error
    render json: { error: 'Search queries pagination is not supported without authentication' }, status: 401
  end

  def remote_resolve_error
    render json: { error: 'Search queries that resolve remote resources are not supported without authentication' }, status: 401
  end

  def handle_fasp_requests
    return unless Mastodon::Feature.fasp_enabled?
    return if params[:q].blank?

    # Do not schedule a new retrieval if the request is a follow-up
    # to an earlier retrieval
    return if request.headers['Mastodon-Async-Refresh-Id'].present?

    refresh_key = "fasp:account_search:#{Digest::MD5.base64digest(params[:q])}"
    return if AsyncRefresh.new(refresh_key).running?

    add_async_refresh_header(AsyncRefresh.create(refresh_key))
    @query_fasp = true
  end

  def remote_resolve_requested?
    truthy_param?(:resolve)
  end

  def pagination_requested?
    params[:offset].present?
  end

  def search_results
    SearchService.new.call(
      params[:q],
      current_account,
      limit_param(RESULTS_LIMIT),
      combined_search_params
    )
  end

  def combined_search_params
    search_params.merge(
      resolve: truthy_param?(:resolve),
      exclude_unreviewed: truthy_param?(:exclude_unreviewed),
      following: truthy_param?(:following),
      query_fasp: @query_fasp
    )
  end

  def search_params
    params.permit(:type, :offset, :min_id, :max_id, :account_id, :following)
  end
end
