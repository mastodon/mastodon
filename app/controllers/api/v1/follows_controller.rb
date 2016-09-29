class Api::V1::FollowsController < ApiController
  before_action :doorkeeper_authorize!
  respond_to    :json

  def create
    raise ActiveRecord::RecordNotFound if params[:uri].blank?

    @account = FollowService.new.call(current_user.account, params[:uri]).try(:target_account)
    render action: :show
  end
end
