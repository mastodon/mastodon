# frozen_string_literal: true

class Api::V1::EndorsementsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:accounts' }
  before_action :require_user!
  after_action :insert_pagination_headers

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
    current_account.endorsed_accounts.includes(:account_stat, :user).without_suspended
  end

  def next_path
    return if unlimited?

    api_v1_endorsements_url pagination_params(max_id: pagination_max_id) if records_continue?
  end

  def prev_path
    return if unlimited?

    api_v1_endorsements_url pagination_params(since_id: pagination_since_id) unless @accounts.empty?
  end

  def pagination_collection
    @accounts
  end

  def records_continue?
    @accounts.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
  end

  def unlimited?
    params[:limit] == '0'
  end
end
