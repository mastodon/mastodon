class Api::V1::StatusesController < ApiController
  before_action -> { doorkeeper_authorize! :read }, except: [:create, :destroy, :reblog, :unreblog, :favourite, :unfavourite]
  before_action -> { doorkeeper_authorize! :write }, only:  [:create, :destroy, :reblog, :unreblog, :favourite, :unfavourite]

  before_action :set_status, only: [:show, :context, :reblogged_by, :favourited_by]

  respond_to :json

  def show
  end

  def context
    @context = OpenStruct.new({ ancestors: @status.ancestors, descendants: @status.descendants })
    set_maps([@status] + @context[:ancestors] + @context[:descendants])
  end

  def reblogged_by
    @accounts = @status.reblogged_by(40)
    render action: :accounts
  end

  def favourited_by
    @accounts = @status.favourited_by(40)
    render action: :accounts
  end

  def create
    @status = PostStatusService.new.call(current_user.account, params[:status], params[:in_reply_to_id].blank? ? nil : Status.find(params[:in_reply_to_id]), params[:media_ids])
    render action: :show
  end

  def destroy
    @status = Status.where(account_id: current_user.account).find(params[:id])
    RemoveStatusService.new.call(@status)
    render_empty
  end

  def reblog
    @status = ReblogService.new.call(current_user.account, Status.find(params[:id])).reload
    render action: :show
  end

  def unreblog
    RemoveStatusService.new.call(Status.where(account_id: current_user.account, reblog_of_id: params[:id]).first!)
    @status = Status.find(params[:id])
    render action: :show
  end

  def favourite
    @status = FavouriteService.new.call(current_user.account, Status.find(params[:id])).status.reload
    render action: :show
  end

  def unfavourite
    @status = UnfavouriteService.new.call(current_user.account, Status.find(params[:id])).status.reload
    render action: :show
  end

  def home
    @statuses = Feed.new(:home, current_user.account).get(20, params[:max_id], params[:since_id]).to_a
    set_maps(@statuses)
    render action: :index
  end

  def mentions
    @statuses = Feed.new(:mentions, current_user.account).get(20, params[:max_id], params[:since_id]).to_a
    set_maps(@statuses)
    render action: :index
  end

  def public
    @statuses = Status.as_public_timeline(current_user.account).paginate_by_max_id(20, params[:max_id], params[:since_id]).to_a
    set_maps(@statuses)
    render action: :index
  end

  private

  def set_status
    @status = Status.find(params[:id])
  end
end
