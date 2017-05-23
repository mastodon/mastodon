# frozen_string_literal: true

class Api::V1::AccountsController < ApiController
  before_action -> { doorkeeper_authorize! :read }, except: [:follow, :unfollow, :block, :unblock, :mute, :unmute]
  before_action -> { doorkeeper_authorize! :follow }, only: [:follow, :unfollow, :block, :unblock, :mute, :unmute]
  before_action :require_user!, except: [:show, :following, :followers]
  before_action :set_account, except: [:suggestions, :search]

  respond_to :json

  def show; end

  def following
    @accounts = Account.includes(:passive_relationships)
                       .references(:passive_relationships)
                       .merge(Follow.where(account: @account)
                                    .paginate_by_max_id(limit_param(DEFAULT_ACCOUNTS_LIMIT), params[:max_id], params[:since_id]))
                       .to_a

    next_path = following_api_v1_account_url(pagination_params(max_id: @accounts.last.passive_relationships.first.id))     if @accounts.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
    prev_path = following_api_v1_account_url(pagination_params(since_id: @accounts.first.passive_relationships.first.id)) unless @accounts.empty?

    set_pagination_headers(next_path, prev_path)

    render :index
  end

  def followers
    @accounts = Account.includes(:active_relationships)
                       .references(:active_relationships)
                       .merge(Follow.where(target_account: @account)
                                    .paginate_by_max_id(limit_param(DEFAULT_ACCOUNTS_LIMIT),
                                                        params[:max_id],
                                                        params[:since_id]))
                       .to_a

    next_path = followers_api_v1_account_url(pagination_params(max_id: @accounts.last.active_relationships.first.id))     if @accounts.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
    prev_path = followers_api_v1_account_url(pagination_params(since_id: @accounts.first.active_relationships.first.id)) unless @accounts.empty?

    set_pagination_headers(next_path, prev_path)

    render :index
  end

  def follow
    FollowService.new.call(current_user.account, @account.acct)
    set_relationship
    render :relationship
  end

  def block
    BlockService.new.call(current_user.account, @account)

    @following       = { @account.id => false }
    @followed_by     = { @account.id => false }
    @blocking        = { @account.id => true }
    @requested       = { @account.id => false }
    @muting          = { @account.id => current_account.muting?(@account.id) }
    @domain_blocking = { @account.id => current_account.domain_blocking?(@account.domain) }

    render :relationship
  end

  def mute
    MuteService.new.call(current_user.account, @account)
    set_relationship
    render :relationship
  end

  def unfollow
    UnfollowService.new.call(current_user.account, @account)
    set_relationship
    render :relationship
  end

  def unblock
    UnblockService.new.call(current_user.account, @account)
    set_relationship
    render :relationship
  end

  def unmute
    UnmuteService.new.call(current_user.account, @account)
    set_relationship
    render :relationship
  end

  def relationships
    ids = params[:id].is_a?(Enumerable) ? params[:id].map(&:to_i) : [params[:id].to_i]

    @accounts        = Account.where(id: ids).select('id')
    @following       = Account.following_map(ids, current_user.account_id)
    @followed_by     = Account.followed_by_map(ids, current_user.account_id)
    @blocking        = Account.blocking_map(ids, current_user.account_id)
    @muting          = Account.muting_map(ids, current_user.account_id)
    @requested       = Account.requested_map(ids, current_user.account_id)
    @domain_blocking = Account.domain_blocking_map(ids, current_user.account_id)
  end

  def search
    @accounts = AccountSearchService.new.call(params[:q], limit_param(DEFAULT_ACCOUNTS_LIMIT), params[:resolve] == 'true', current_account)

    render :index
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end

  def set_relationship
    @following       = Account.following_map([@account.id], current_user.account_id)
    @followed_by     = Account.followed_by_map([@account.id], current_user.account_id)
    @blocking        = Account.blocking_map([@account.id], current_user.account_id)
    @muting          = Account.muting_map([@account.id], current_user.account_id)
    @requested       = Account.requested_map([@account.id], current_user.account_id)
    @domain_blocking = Account.domain_blocking_map([@account.id], current_user.account_id)
  end

  def pagination_params(core_params)
    params.permit(:limit).merge(core_params)
  end
end
