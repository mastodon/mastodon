# frozen_string_literal: true

class Api::V1::EndorsementsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:accounts' }
  before_action :require_user!
  after_action :insert_pagination_headers

  respond_to :json

  def index
    @accounts = load_accounts
    render json: @accounts, each_serializer: REST::AccountSerializer
  end

  private

  def load_accounts
    if unlimited?
      endorsed_accounts.all
    else
      endorsed_accounts.paginate_by_max_id(
        limit_param(DEFAULT_ACCOUNTS_LIMIT),
        params[:max_id],
        params[:since_id]
      )
    end
  end

  def endorsed_accounts
    current_account.endorsed_accounts
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def next_path
    return if unlimited?

    if records_continue?
      api_v1_endorsements_url pagination_params(max_id: pagination_max_id)
    end
  end

  def prev_path
    return if unlimited?

    unless @accounts.empty?
      api_v1_endorsements_url pagination_params(since_id: pagination_since_id)
    end
  end

  def pagination_max_id
    @accounts.last.id
  end

  def pagination_since_id
    @accounts.first.id
  end

  def records_continue?
    @accounts.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
  end

  def pagination_params(core_params)
    params.slice(:limit).permit(:limit).merge(core_params)
  end

  def unlimited?
    params[:limit] == '0'
  end
end
