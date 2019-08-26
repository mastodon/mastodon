# frozen_string_literal: true

class Api::V1::HideReblogsController < Api::BaseController
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
    default_accounts.merge(paginated_follows).to_a
  end

  def default_accounts
    Account.includes(:passive_relationships, :account_stat).references(:passive_relationships)
  end

  def paginated_follows
    current_account.active_relationships.where(show_reblogs: false).paginate_by_max_id(
      limit_param(DEFAULT_ACCOUNTS_LIMIT),
      params[:max_id],
      params[:since_id]
    )
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def next_path
    api_v1_hide_reblogs_url pagination_params(max_id: pagination_max_id) if records_continue?
  end

  def prev_path
    api_v1_hide_reblogs_url pagination_params(min_id: pagination_since_id) unless @accounts.empty?
  end

  def pagination_max_id
    @accounts.last.passive_relationships.first.id
  end

  def pagination_since_id
    @accounts.first.passive_relationships.first.id
  end

  def records_continue?
    @accounts.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
  end

  def pagination_params(core_params)
    params.slice(:limit).permit(:limit).merge(core_params)
  end
end
