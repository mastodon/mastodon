# frozen_string_literal: true

class Api::V1::Accounts::CirclesController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:circles' }
  before_action :require_user!
  before_action :set_account

  def index
    @circles = @account.circles.where(account: current_account)
    render json: @circles, each_serializer: REST::CircleSerializer
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  end
end
