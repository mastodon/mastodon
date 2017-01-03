# frozen_string_literal: true

class Api::V1::FollowRequestsController < ApiController
  before_action -> { doorkeeper_authorize! :follow }
  before_action :require_user!

  def index
    results   = FollowRequest.where(target_account: current_account).paginate_by_max_id(DEFAULT_ACCOUNTS_LIMIT, params[:max_id], params[:since_id])
    accounts  = Account.where(id: results.map(&:account_id)).map { |a| [a.id, a] }.to_h
    @accounts = results.map { |f| accounts[f.account_id] }

    set_account_counters_maps(@accounts)

    next_path = api_v1_follow_requests_url(max_id: results.last.id)    if results.size == DEFAULT_ACCOUNTS_LIMIT
    prev_path = api_v1_follow_requests_url(since_id: results.first.id) unless results.empty?

    set_pagination_headers(next_path, prev_path)
  end

  def authorize
    FollowRequest.find_by!(account_id: params[:id], target_account: current_account).authorize!
    render_empty
  end

  def reject
    FollowRequest.find_by!(account_id: params[:id], target_account: current_account).reject!
    render_empty
  end
end
