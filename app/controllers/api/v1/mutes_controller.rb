# frozen_string_literal: true

class Api::V1::MutesController < ApiController
  before_action -> { doorkeeper_authorize! :follow }
  before_action :require_user!

  respond_to :json

  def index
    @accounts = Account.includes(:muted_by)
                       .references(:muted_by)
                       .merge(Mute.where(account: current_account)
                                  .paginate_by_max_id(limit_param(DEFAULT_ACCOUNTS_LIMIT), params[:max_id], params[:since_id]))
                       .to_a

    next_path = api_v1_mutes_url(pagination_params(max_id: @accounts.last.muted_by_ids.last))     if @accounts.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
    prev_path = api_v1_mutes_url(pagination_params(since_id: @accounts.first.muted_by_ids.first)) unless @accounts.empty?

    set_pagination_headers(next_path, prev_path)
  end

  private

  def pagination_params(core_params)
    params.permit(:limit).merge(core_params)
  end
end
