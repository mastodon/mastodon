class Api::FollowsController < ApiController
  before_action :doorkeeper_authorize!
  respond_to    :json

  def create
    @follow = FollowService.new.(current_user.account, params[:uri])
    render action: :show
  end
end
