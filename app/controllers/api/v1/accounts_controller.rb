class Api::V1::AccountsController < ApiController
  before_action :doorkeeper_authorize!
  before_action :set_account, except: [:verify_credentials, :suggestions]
  respond_to    :json

  def show
  end

  def verify_credentials
    @account = current_user.account
    render action: :show
  end

  def following
    @following = @account.following
  end

  def followers
    @followers = @account.followers
  end

  def suggestions
    @accounts = FollowSuggestion.get(current_user.account_id)
  end

  def statuses
    @statuses = @account.statuses.with_includes.with_counters.paginate_by_max_id(20, params[:max_id], params[:since_id]).to_a
  end

  def follow
    FollowService.new.call(current_user.account, @account.acct)
    set_relationship
    render action: :relationship
  end

  def block
    BlockService.new.call(current_user.account, @account)
    set_relationship
    render action: :relationship
  end

  def unfollow
    UnfollowService.new.call(current_user.account, @account)
    set_relationship
    render action: :relationship
  end

  def unblock
    UnblockService.new.call(current_user.account, @account)
    set_relationship
    render action: :relationship
  end

  def relationships
    ids = params[:id].is_a?(Enumerable) ? params[:id].map(&:to_i) : [params[:id].to_i]
    @accounts    = Account.find(ids)
    @following   = Account.following_map(ids, current_user.account_id)
    @followed_by = Account.followed_by_map(ids, current_user.account_id)
    @blocking    = Account.blocking_map(ids, current_user.account_id)
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end

  def set_relationship
    @following   = Account.following_map([@account.id], current_user.account_id)
    @followed_by = Account.followed_by_map([@account.id], current_user.account_id)
    @blocking    = Account.blocking_map([@account.id], current_user.account_id)
  end
end
