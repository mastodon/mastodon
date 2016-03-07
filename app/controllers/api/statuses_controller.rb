class Api::StatusesController < ApiController
  before_action :authenticate_user!
  respond_to    :json

  def show
    @status = Status.find(params[:id])
  end

  def create
    @status = PostStatusService.new.(current_user.account, params[:status], params[:in_reply_to_id].blank? ? nil : Status.find(params[:in_reply_to_id]))
    render action: :show
  end

  def reblog
    @status = ReblogService.new.(current_user.account, Status.find(params[:id]))
    render action: :show
  end
end
