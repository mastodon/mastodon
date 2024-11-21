# frozen_string_literal: true

class Api::V1::FollowRequestsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :follow, :read, :'read:follows' }, only: :index
  before_action -> { doorkeeper_authorize! :follow, :write, :'write:follows' }, except: :index
  before_action :require_user!
  after_action :insert_pagination_headers, only: :index

  def index
    @accounts = load_accounts
    render json: @accounts, each_serializer: REST::AccountSerializer
  end

  def authorize
    AuthorizeFollowService.new.call(account, current_account)
    LocalNotificationWorker.perform_async(current_account.id, Follow.find_by(account: account, target_account: current_account).id, 'Follow', 'follow')
    render json: account, serializer: REST::RelationshipSerializer, relationships: relationships
  end

  def reject
    RejectFollowService.new.call(account, current_account)
    render json: account, serializer: REST::RelationshipSerializer, relationships: relationships
  end

  private

  def account
    @account ||= Account.find(params[:id])
  end

  def relationships(**)
    AccountRelationshipsPresenter.new([account], current_user.account_id, **)
  end

  def load_accounts
    default_accounts.merge(paginated_follow_requests).to_a
  end

  def default_accounts
    Account.without_suspended.includes(:follow_requests, :account_stat, :user).references(:follow_requests)
  end

  def paginated_follow_requests
    FollowRequest.where(target_account: current_account).paginate_by_max_id(
      limit_param(DEFAULT_ACCOUNTS_LIMIT),
      params[:max_id],
      params[:since_id]
    )
  end

  def next_path
    api_v1_follow_requests_url pagination_params(max_id: pagination_max_id) if records_continue?
  end

  def prev_path
    api_v1_follow_requests_url pagination_params(since_id: pagination_since_id) unless @accounts.empty?
  end

  def pagination_max_id
    @accounts.last.follow_requests.last.id
  end

  def pagination_since_id
    @accounts.first.follow_requests.first.id
  end

  def records_continue?
    @accounts.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
  end
end
