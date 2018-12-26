# frozen_string_literal: true

class Api::V1::Accounts::ListsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!
  before_action :set_account

  respond_to :json

  def index
    @lists = @account.lists.where(account: current_account)
    render json: @lists, each_serializer: REST::ListSerializer
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  end
end
