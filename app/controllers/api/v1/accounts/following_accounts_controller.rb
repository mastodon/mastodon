# frozen_string_literal: true

class Api::V1::Accounts::FollowingAccountsController < ApiController
  before_action -> { doorkeeper_authorize! :read }
  before_action :set_account
  after_action :insert_pagination_headers

  respond_to :json

  def index
    @accounts = load_accounts
    render 'api/v1/accounts/index'
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  end

  def load_accounts
    default_accounts.merge(paginated_follows).to_a
  end

  def default_accounts
    Account.includes(:passive_relationships).references(:passive_relationships)
  end

  def paginated_follows
    Follow.where(account: @account).paginate_by_max_id(
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
      api_v1_account_following_index_url pagination_params(max_id: pagination_max_id)
    end
  end

  def prev_path
    unless @accounts.empty?
      api_v1_account_following_index_url pagination_params(since_id: pagination_since_id)
    end
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
    params.permit(:limit).merge(core_params)
  end
end
