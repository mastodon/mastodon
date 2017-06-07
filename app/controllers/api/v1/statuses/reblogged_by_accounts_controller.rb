# frozen_string_literal: true

class Api::V1::Statuses::RebloggedByAccountsController < Api::BaseController
  include Authorization

  before_action :authorize_if_got_token
  before_action :set_status

  respond_to :json

  def index
    @accounts = Account.includes(:statuses)
                       .references(:statuses)
                       .merge(Status.where(reblog_of_id: @status.id)
                                    .paginate_by_max_id(limit_param(DEFAULT_ACCOUNTS_LIMIT), params[:max_id], params[:since_id]))
                       .to_a

    next_path = api_v1_status_reblogged_by_index_url(pagination_params(max_id: @accounts.last.statuses.last.id))     if @accounts.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
    prev_path = api_v1_status_reblogged_by_index_url(pagination_params(since_id: @accounts.first.statuses.first.id)) unless @accounts.empty?

    set_pagination_headers(next_path, prev_path)

    render 'api/v1/statuses/accounts'
  end

  private

  def set_status
    @status = Status.find(params[:status_id])
    authorize @status, :show?
  rescue Mastodon::NotPermittedError
    # Reraise in order to get a 404 instead of a 403 error code
    raise ActiveRecord::RecordNotFound
  end

  def authorize_if_got_token
    request_token = Doorkeeper::OAuth::Token.from_request(request, *Doorkeeper.configuration.access_token_methods)
    doorkeeper_authorize! :read if request_token
  end

  def pagination_params(core_params)
    params.permit(:limit).merge(core_params)
  end
end
