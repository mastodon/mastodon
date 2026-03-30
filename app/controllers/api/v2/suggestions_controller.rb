# frozen_string_literal: true

class Api::V2::SuggestionsController < Api::BaseController
  include Authorization
  include AsyncRefreshesConcern

  before_action -> { doorkeeper_authorize! :read, :'read:accounts' }, only: :index
  before_action -> { doorkeeper_authorize! :write, :'write:accounts' }, except: :index
  before_action :require_user!
  before_action :set_suggestions
  before_action :schedule_fasp_retrieval

  def index
    render json: @suggestions.get(limit_param(DEFAULT_ACCOUNTS_LIMIT), params[:offset].to_i), each_serializer: REST::SuggestionSerializer
  end

  def destroy
    @suggestions.remove(params[:id])
    render_empty
  end

  private

  def set_suggestions
    @suggestions = AccountSuggestions.new(current_account)
  end

  def schedule_fasp_retrieval
    return unless Mastodon::Feature.fasp_enabled?
    # Do not schedule a new retrieval if the request is a follow-up
    # to an earlier retrieval
    return if request.headers['Mastodon-Async-Refresh-Id'].present?

    refresh_key = "fasp:follow_recommendation:#{current_account.id}"
    return if AsyncRefresh.new(refresh_key).running?

    add_async_refresh_header(AsyncRefresh.create(refresh_key))

    Fasp::FollowRecommendationWorker.perform_async(current_account.id)
  end
end
