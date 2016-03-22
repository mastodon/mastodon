class Api::StatusesController < ApiController
  before_action :doorkeeper_authorize!
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

  def favourite
    @status = FavouriteService.new.(current_user.account, Status.find(params[:id])).status
    render action: :show
  end

  def home
    feed      = Feed.new(:home, current_user.account)
    @statuses = feed.get(20, params[:max_id] || '+inf')
  end

  def mentions
    feed      = Feed.new(:mentions, current_user.account)
    @statuses = feed.get(20, params[:max_id] || '+inf')
  end
end
