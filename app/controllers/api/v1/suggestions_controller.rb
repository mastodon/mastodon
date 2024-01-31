# frozen_string_literal: true

class Api::V1::SuggestionsController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :read, :'read:accounts' }, only: :index
  before_action -> { doorkeeper_authorize! :write, :'write:accounts' }, except: :index
  before_action :require_user!
  before_action :set_suggestions_accounts

  def index
    render json: @accounts, each_serializer: REST::AccountSerializer
  end

  def destroy
    account_suggestions.remove(params[:id])
    render_empty
  end

  private

  def account_suggestions
    AccountSuggestions.new(current_account)
  end

  def set_suggestions_accounts
    @accounts = limited_account_suggestions.map(&:account)
  end

  def limited_account_suggestions
    account_suggestions.get(
      limit_param(DEFAULT_ACCOUNTS_LIMIT),
      params[:offset].to_i
    )
  end
end
