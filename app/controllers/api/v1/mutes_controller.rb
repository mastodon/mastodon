# frozen_string_literal: true

class Api::V1::MutesController < Api::BaseController
  before_action -> { doorkeeper_authorize! :follow }
  before_action :require_user!
  after_action :insert_pagination_headers

  respond_to :json

  def index
    @accounts = load_accounts
  end

  private

  def load_accounts
    default_accounts.merge(paginated_mutes).to_a
  end

  def default_accounts
    Account.includes(:muted_by).references(:muted_by)
  end

  def paginated_mutes
    Mute.where(account: current_account).paginate_by_max_id(
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
      api_v1_mutes_url pagination_params(max_id: pagination_max_id)
    end
  end

  def prev_path
    unless @accounts.empty?
      api_v1_mutes_url pagination_params(since_id: pagination_since_id)
    end
  end

  def pagination_max_id
    @accounts.last.muted_by_ids.last
  end

  def pagination_since_id
    @accounts.first.muted_by_ids.first
  end

  def records_continue?
    @accounts.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
  end

  def pagination_params(core_params)
    params.permit(:limit).merge(core_params)
  end
end
