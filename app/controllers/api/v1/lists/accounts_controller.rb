# frozen_string_literal: true

class Api::V1::Lists::AccountsController < Api::BaseController
  include Authorization

  before_action -> { authorize_if_got_token! :read, :'read:lists' }, only: [:show]
  before_action -> { doorkeeper_authorize! :write, :'write:lists' }, except: [:show]

  before_action :require_user!, except: [:show]
  before_action :set_list

  after_action :insert_pagination_headers, only: :show

  def show
    authorize @list, :show?
    @accounts = load_accounts
    render json: @accounts, each_serializer: REST::AccountSerializer
  end

  def create
    authorize @list, :update?
    AddAccountsToListService.new.call(@list, Account.find(account_ids))
    render_empty
  end

  def destroy
    authorize @list, :update?
    RemoveAccountsFromListService.new.call(@list, Account.where(id: account_ids))
    render_empty
  end

  private

  def set_list
    @list = List.find(params[:list_id])
  end

  def load_accounts
    if unlimited?
      @list.accounts.without_suspended.includes(:account_stat, :user).all
    else
      @list.accounts.without_suspended.includes(:account_stat, :user).paginate_by_max_id(limit_param(DEFAULT_ACCOUNTS_LIMIT), params[:max_id], params[:since_id])
    end
  end

  def account_ids
    Array(resource_params[:account_ids])
  end

  def resource_params
    params.permit(account_ids: [])
  end

  def next_path
    return if unlimited?

    api_v1_list_accounts_url pagination_params(max_id: pagination_max_id) if records_continue?
  end

  def prev_path
    return if unlimited?

    api_v1_list_accounts_url pagination_params(since_id: pagination_since_id) unless @accounts.empty?
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
