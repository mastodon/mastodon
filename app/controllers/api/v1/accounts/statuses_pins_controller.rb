class Api::V1::Accounts::StatusesPinsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!

  respond_to :json

  def index
    @pins_statuses = cache_collection(current_account.pinned_statuses, Status)
    render json: @pins_statuses, each_serializer: REST::StatusSerializer
  end
end
