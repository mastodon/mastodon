# frozen_string_literal: true

class Api::V1::AccountsController < ApiController
  before_action -> { doorkeeper_authorize! :read }, except: [:follow, :unfollow, :block, :unblock, :mute, :unmute, :update_credentials]
  before_action -> { doorkeeper_authorize! :follow }, only: [:follow, :unfollow, :block, :unblock, :mute, :unmute]
  before_action -> { doorkeeper_authorize! :write }, only: [:update_credentials]
  before_action :require_user!, except: [:show, :following, :followers, :statuses]
  before_action :set_account, except: [:verify_credentials, :update_credentials, :suggestions, :search]

  respond_to :json

  def show; end

  def verify_credentials
    @account = current_user.account
    render action: :show
  end

  def update_credentials
    current_account.update!(account_params)
    @account = current_account
    render action: :show
  end

  def following
    results   = Follow.where(account: @account).paginate_by_max_id(limit_param(DEFAULT_ACCOUNTS_LIMIT), params[:max_id], params[:since_id])
    accounts  = Account.where(id: results.map(&:target_account_id)).map { |a| [a.id, a] }.to_h
    @accounts = results.map { |f| accounts[f.target_account_id] }

    next_path = following_api_v1_account_url(pagination_params(max_id: results.last.id))    if results.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
    prev_path = following_api_v1_account_url(pagination_params(since_id: results.first.id)) unless results.empty?

    set_pagination_headers(next_path, prev_path)

    render action: :index
  end

  def followers
    results   = Follow.where(target_account: @account).paginate_by_max_id(limit_param(DEFAULT_ACCOUNTS_LIMIT), params[:max_id], params[:since_id])
    accounts  = Account.where(id: results.map(&:account_id)).map { |a| [a.id, a] }.to_h
    @accounts = results.map { |f| accounts[f.account_id] }

    next_path = followers_api_v1_account_url(pagination_params(max_id: results.last.id))    if results.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
    prev_path = followers_api_v1_account_url(pagination_params(since_id: results.first.id)) unless results.empty?

    set_pagination_headers(next_path, prev_path)

    render action: :index
  end

  def statuses
    @statuses = @account.statuses.permitted_for(@account, current_account).paginate_by_max_id(limit_param(DEFAULT_STATUSES_LIMIT), params[:max_id], params[:since_id])
    @statuses = @statuses.where(id: MediaAttachment.where(account: @account).where.not(status_id: nil).reorder('').select('distinct status_id')) if params[:only_media]
    @statuses = @statuses.without_replies if params[:exclude_replies]
    @statuses = cache_collection(@statuses, Status)

    set_maps(@statuses)

    next_path = statuses_api_v1_account_url(statuses_pagination_params(max_id: @statuses.last.id))    unless @statuses.empty?
    prev_path = statuses_api_v1_account_url(statuses_pagination_params(since_id: @statuses.first.id)) unless @statuses.empty?

    set_pagination_headers(next_path, prev_path)
  end

  def follow
    FollowService.new.call(current_user.account, @account.acct)
    set_relationship
    render action: :relationship
  end

  def block
    BlockService.new.call(current_user.account, @account)

    @following   = { @account.id => false }
    @followed_by = { @account.id => false }
    @blocking    = { @account.id => true }
    @requested   = { @account.id => false }
    @muting      = { @account.id => current_user.account.muting?(@account.id) }

    render action: :relationship
  end

  def mute
    MuteService.new.call(current_user.account, @account)
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

  def unmute
    UnmuteService.new.call(current_user.account, @account)
    set_relationship
    render action: :relationship
  end

  def relationships
    ids = params[:id].is_a?(Enumerable) ? params[:id].map(&:to_i) : [params[:id].to_i]

    @accounts    = Account.where(id: ids).select('id')
    @following   = Account.following_map(ids, current_user.account_id)
    @followed_by = Account.followed_by_map(ids, current_user.account_id)
    @blocking    = Account.blocking_map(ids, current_user.account_id)
    @muting      = Account.muting_map(ids, current_user.account_id)
    @requested   = Account.requested_map(ids, current_user.account_id)
  end

  def search
    @accounts = AccountSearchService.new.call(params[:q], limit_param(DEFAULT_ACCOUNTS_LIMIT), params[:resolve] == 'true', current_account)

    render action: :index
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end

  def set_relationship
    @following   = Account.following_map([@account.id], current_user.account_id)
    @followed_by = Account.followed_by_map([@account.id], current_user.account_id)
    @blocking    = Account.blocking_map([@account.id], current_user.account_id)
    @muting      = Account.muting_map([@account.id], current_user.account_id)
    @requested   = Account.requested_map([@account.id], current_user.account_id)
  end

  def pagination_params(core_params)
    params.permit(:limit).merge(core_params)
  end

  def statuses_pagination_params(core_params)
    params.permit(:limit, :only_media, :exclude_replies).merge(core_params)
  end

  def account_params
    params.permit(:display_name, :note, :avatar, :header)
  end
end
