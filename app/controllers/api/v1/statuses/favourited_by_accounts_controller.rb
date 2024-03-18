# frozen_string_literal: true

class Api::V1::Statuses::FavouritedByAccountsController < Api::V1::Statuses::BaseController
  before_action -> { authorize_if_got_token! :read, :'read:accounts' }
  after_action :insert_pagination_headers

  def index
    cache_if_unauthenticated!
    @accounts = load_accounts
    render json: @accounts, each_serializer: REST::AccountSerializer
  end

  private

  def load_accounts
    scope = default_accounts
    scope = scope.not_excluded_by_account(current_account) unless current_account.nil?
    scope.merge(paginated_favourites).to_a
  end

  def default_accounts
    Account
      .without_suspended
      .includes(:favourites, :account_stat, :user)
      .references(:favourites)
      .where(favourites: { status_id: @status.id })
  end

  def paginated_favourites
    Favourite.paginate_by_max_id(
      limit_param(DEFAULT_ACCOUNTS_LIMIT),
      params[:max_id],
      params[:since_id]
    )
  end

  def next_path
    api_v1_status_favourited_by_index_url pagination_params(max_id: pagination_max_id) if records_continue?
  end

  def prev_path
    api_v1_status_favourited_by_index_url pagination_params(since_id: pagination_since_id) unless @accounts.empty?
  end

  def pagination_max_id
    @accounts.last.favourites.last.id
  end

  def pagination_since_id
    @accounts.first.favourites.first.id
  end

  def records_continue?
    @accounts.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
  end

  def pagination_params(core_params)
    params.slice(:limit).permit(:limit).merge(core_params)
  end
end
