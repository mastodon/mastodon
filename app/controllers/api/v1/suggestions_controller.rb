# frozen_string_literal: true

class Api::V1::SuggestionsController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!
  before_action :set_accounts

  respond_to :json

  def index
    render json: @accounts, each_serializer: REST::AccountSerializer
  end

  def destroy
    PotentialFriendshipTracker.remove(current_account.id, params[:id])
    render_empty
  end

  private

  def set_accounts
    @accounts = PotentialFriendshipTracker.get(current_account.id, limit: limit_param(DEFAULT_ACCOUNTS_LIMIT))
  end
end
