# frozen_string_literal: true

class Api::V1::MutesController < ApiController
  before_action -> { doorkeeper_authorize! :follow }
  before_action :require_user!

  respond_to :json

  def index
    results   = Mute.where(account: current_account).paginate_by_max_id(limit_param(DEFAULT_ACCOUNTS_LIMIT), params[:max_id], params[:since_id])
    accounts  = Account.where(id: results.map(&:target_account_id)).map { |a| [a.id, a] }.to_h
    @accounts = results.map { |f| accounts[f.target_account_id] }

    next_path = api_v1_mutes_url(pagination_params(max_id: results.last.id))    if results.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
    prev_path = api_v1_mutes_url(pagination_params(since_id: results.first.id)) unless results.empty?

    set_pagination_headers(next_path, prev_path)
  end

  private

  def pagination_params(core_params)
    params.permit(:limit).merge(core_params)
  end
end
