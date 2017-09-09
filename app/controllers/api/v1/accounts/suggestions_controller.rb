# frozen_string_literal: true

class Api::V1::Accounts::SuggestionsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!

  respond_to :json

  def index
    @accounts = Account.triadic_closures(current_account)
    render json: @accounts, each_serializer: REST::AccountSerializer
  end
end
