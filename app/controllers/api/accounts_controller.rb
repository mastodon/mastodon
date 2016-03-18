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
    @statuses = @account.statuses.with_includes.with_counters.order('created_at desc')
  end

  def follow
    if @account.local?
      @follow = current_user.account.follow!(@account)
    else
      @follow = FollowService.new.(current_user.account, @account.acct)
    end

    render action: :show
  end

  def unfollow
    @unfollow = UnfollowService.new.(current_user.account, @account)
    render action: :show
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end
end
