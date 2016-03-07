class Api::AccountsController < ApiController
  before_action :set_account
  before_action :authenticate_user!
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
    @statuses = @account.statuses.order('created_at desc')
  end

  def follow
    @follow = current_user.account.follow!(@account)
    render action: :show
  end

  def unfollow
    @unfollow = current_user.account.unfollow!(@account)
    render action: :show
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end
end
