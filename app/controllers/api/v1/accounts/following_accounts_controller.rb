# frozen_string_literal: true

class Api::V1::Accounts::FollowingAccountsController < Api::BaseController
  before_action -> { authorize_if_got_token! :read, :'read:accounts' }
  before_action :set_account
  after_action :insert_pagination_headers

  def index
    cache_if_unauthenticated!
    @accounts = load_accounts
    render json: @accounts, each_serializer: REST::AccountSerializer
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  end

  def load_accounts
    return [] if hide_results?

    scope = default_accounts
    scope = scope.not_excluded_by_account(current_account) unless current_account.nil? || current_account.id == @account.id
    scope.merge(paginated_follows).to_a
  end

  def hide_results?
    @account.unavailable? || (@account.hides_following? && current_account&.id != @account.id) || (current_account && @account.blocking?(current_account))
  end

  def default_accounts
    Account.includes(:passive_relationships, :account_stat, :user).references(:passive_relationships)
  end

  def paginated_follows
    Follow.where(account: @account).paginate_by_max_id(
      limit_param(DEFAULT_ACCOUNTS_LIMIT),
      params[:max_id],
      params[:since_id]
    )
  end

  def next_path
    api_v1_account_following_index_url pagination_params(max_id: pagination_max_id) if records_continue?
  end

  def prev_path
    api_v1_account_following_index_url pagination_params(since_id: pagination_since_id) unless @accounts.empty?
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
end
