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

  private

  def triadic_closures
    Account.triadic_closures(current_account, limit: DEFAULT_ACCOUNTS_LIMIT)
  end

  def potential_friendships
    PotentialFriendshipTracker.get(current_account.id, limit: DEFAULT_ACCOUNTS_LIMIT)
  end

  def set_accounts
    @accounts = triadic_closures | potential_friendships
  end
end
