# frozen_string_literal: true

class Api::V1::FollowRequestsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :follow }
  before_action :require_user!
  after_action :insert_pagination_headers, only: :index

  def index
    @accounts = load_accounts
  end

  def authorize
    AuthorizeFollowService.new.call(account, current_account)
    render_empty
  end

  def reject
    RejectFollowService.new.call(account, current_account)
    render_empty
  end

  private

  def account
    Account.find(params[:id])
  end

  def load_accounts
    default_accounts.merge(paginated_follow_requests).to_a
  end

  def default_accounts
    Account.includes(:follow_requests).references(:follow_requests)
  end

  def paginated_follow_requests
    FollowRequest.where(target_account: current_account).paginate_by_max_id(
      limit_param(DEFAULT_ACCOUNTS_LIMIT),
      params[:max_id],
      params[:since_id]
    )
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def next_path
    if records_continue?
      api_v1_follow_requests_url pagination_params(max_id: pagination_max_id)
    end
  end

  def prev_path
    unless @accounts.empty?
      api_v1_follow_requests_url pagination_params(since_id: pagination_since_id)
    end
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

  def pagination_params(core_params)
    params.permit(:limit).merge(core_params)
  end
end
