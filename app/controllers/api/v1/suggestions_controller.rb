# frozen_string_literal: true

class Api::V1::SuggestionsController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!

  def index
    suggestions = suggestions_source.get(current_account, limit: limit_param(DEFAULT_ACCOUNTS_LIMIT))
    render json: suggestions.map(&:account), each_serializer: REST::AccountSerializer
  end

  def destroy
    suggestions_source.remove(current_account, params[:id])
    render_empty
  end

  private

  def suggestions_source
    AccountSuggestions::PastInteractionsSource.new
  end
end
