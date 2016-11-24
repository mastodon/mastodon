# frozen_string_literal: true

class Api::V1::AccountsController < ApiController
  before_action -> { doorkeeper_authorize! :read }, except: [:follow, :unfollow, :block, :unblock]
  before_action -> { doorkeeper_authorize! :follow }, only: [:follow, :unfollow, :block, :unblock]
  before_action :require_user!, except: [:show, :following, :followers, :statuses]
  before_action :set_account, except: [:verify_credentials, :suggestions, :search]

  respond_to :json

  def show
  end

  def verify_credentials
    @account = current_user.account
    render action: :show
  end

  def following
    results   = Follow.where(account: @account).paginate_by_max_id(DEFAULT_ACCOUNTS_LIMIT, params[:max_id], params[:since_id])
    accounts  = Account.where(id: results.map(&:target_account_id)).map { |a| [a.id, a] }.to_h
    @accounts = results.map { |f| accounts[f.target_account_id] }

    set_account_counters_maps(@accounts)

    next_path = following_api_v1_account_url(max_id: results.last.id)    if results.size == DEFAULT_ACCOUNTS_LIMIT
    prev_path = following_api_v1_account_url(since_id: results.first.id) unless results.empty?

    set_pagination_headers(next_path, prev_path)

    render action: :index
  end

  def followers
    results   = Follow.where(target_account: @account).paginate_by_max_id(DEFAULT_ACCOUNTS_LIMIT, params[:max_id], params[:since_id])
    accounts  = Account.where(id: results.map(&:account_id)).map { |a| [a.id, a] }.to_h
    @accounts = results.map { |f| accounts[f.account_id] }

    set_account_counters_maps(@accounts)

    next_path = followers_api_v1_account_url(max_id: results.last.id)    if results.size == DEFAULT_ACCOUNTS_LIMIT
    prev_path = followers_api_v1_account_url(since_id: results.first.id) unless results.empty?

    set_pagination_headers(next_path, prev_path)

    render action: :index
  end

  def statuses
    @statuses = @account.statuses.paginate_by_max_id(DEFAULT_STATUSES_LIMIT, params[:max_id], params[:since_id]).to_a
    @statuses = cache(@statuses)

    set_maps(@statuses)
    set_counters_maps(@statuses)

    next_path = statuses_api_v1_account_url(max_id: @statuses.last.id)    if @statuses.size == DEFAULT_STATUSES_LIMIT
    prev_path = statuses_api_v1_account_url(since_id: @statuses.first.id) unless @statuses.empty?

    set_pagination_headers(next_path, prev_path)
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
    @accounts    = Account.where(id: ids).select('id')
    @following   = Account.following_map(ids, current_user.account_id)
    @followed_by = Account.followed_by_map(ids, current_user.account_id)
    @blocking    = Account.blocking_map(ids, current_user.account_id)
  end

  def search
    limit = params[:limit] ? [DEFAULT_ACCOUNTS_LIMIT, params[:limit].to_i].min : DEFAULT_ACCOUNTS_LIMIT
    @accounts = SearchService.new.call(params[:q], limit, params[:resolve] == 'true')

    set_account_counters_maps(@accounts)

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
  end

  def cache(raw)
    uncached_ids           = []
    cached_keys_with_value = Rails.cache.read_multi(*raw.map(&:cache_key))

    raw.each do |status|
      uncached_ids << status.id unless cached_keys_with_value.key?(status.cache_key)
    end

    unless uncached_ids.empty?
      uncached = Status.where(id: uncached_ids).with_includes.map { |s| [s.id, s] }.to_h

      uncached.values.each do |status|
        Rails.cache.write(status.cache_key, status)
      end
    end

    raw.map { |status| cached_keys_with_value[status.cache_key] || uncached[status.id] }
  end
end
