# frozen_string_literal: true

class Api::V2::SuggestionsController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!
  before_action :set_suggestions

  def index
    render json: @suggestions, each_serializer: REST::SuggestionSerializer
  end

  private

  def set_suggestions
    @suggestions = AccountSuggestions.get(current_account, limit_param(DEFAULT_ACCOUNTS_LIMIT))
  end
end
