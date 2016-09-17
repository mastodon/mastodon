class Api::FollowsController < ApiController
  before_action :doorkeeper_authorize!
  respond_to    :json

  def create
    if params[:uri].blank?
      raise ActiveRecord::RecordNotFound
    end

    @account = FollowService.new.(current_user.account, params[:uri]).try(:target_account)
    render action: :show
  end
end
