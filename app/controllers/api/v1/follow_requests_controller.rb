# frozen_string_literal: true

class Api::V1::FollowRequestsController < ApiController
  before_action -> { doorkeeper_authorize! :follow }
  before_action :require_user!

  def index
    @accounts = Account.includes(:follow_requests)
                       .references(:follow_requests)
                       .merge(FollowRequest.where(target_account: current_account)
                                           .paginate_by_max_id(DEFAULT_ACCOUNTS_LIMIT, params[:max_id], params[:since_id]))
                       .to_a

    next_path = api_v1_follow_requests_url(pagination_params(max_id: @accounts.last.follow_requests.last.id))     if @accounts.size == DEFAULT_ACCOUNTS_LIMIT
    prev_path = api_v1_follow_requests_url(pagination_params(since_id: @accounts.first.follow_requests.first.id)) unless @accounts.empty?

    set_pagination_headers(next_path, prev_path)
  end

  def authorize
    AuthorizeFollowService.new.call(Account.find(params[:id]), current_account)
    render_empty
  end

  def reject
    RejectFollowService.new.call(Account.find(params[:id]), current_account)
    render_empty
  end

  private

  def pagination_params(core_params)
    params.permit(:limit).merge(core_params)
  end
end
