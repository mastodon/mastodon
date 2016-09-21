class Api::AccountsController < ApiController
  before_action :set_account
  before_action :doorkeeper_authorize!
  respond_to    :json

  def show
  end

  def following
    @following = @account.following
  end

  def followers
    @followers = @account.followers
  end

  def statuses
    @statuses = @account.statuses.with_includes.with_counters.paginate_by_max_id(20, params[:max_id] || nil).to_a
  end

  def follow
    @follow = FollowService.new.(current_user.account, @account.acct)
    render action: :show
  end

  def unfollow
    @unfollow = UnfollowService.new.(current_user.account, @account)
    render action: :show
  end

  def relationships
    ids = params[:id].is_a?(Enumerable) ? params[:id].map { |id| id.to_i } : [params[:id].to_i]
    @accounts    = Account.find(ids)
    @following   = Account.following_map(ids, current_user.account_id)
    @followed_by = Account.followed_by_map(ids, current_user.account_id)
    @blocking    = {}
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end
end
