# frozen_string_literal: true

class Api::V1::Lists::AccountsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:lists' }, only: [:show]
  before_action -> { doorkeeper_authorize! :write, :'write:lists' }, except: [:show]

  before_action :require_user!
  before_action :set_list

  after_action :insert_pagination_headers, only: :show

  def show
    @accounts = load_accounts
    render json: @accounts, each_serializer: REST::AccountSerializer
  end

  def create
    ApplicationRecord.transaction do
      list_accounts.each do |account|
        @list.accounts << account
      end
    end

    render_empty
  end

  def destroy
    ListAccount.where(list: @list, account_id: account_ids).destroy_all
    render_empty
  end

  private

  def set_list
    @list = List.where(account: current_account).find(params[:list_id])
  end

  def load_accounts
    if unlimited?
      @list.accounts.without_suspended.includes(:account_stat, :user).all
    else
      @list.accounts.without_suspended.includes(:account_stat, :user).paginate_by_max_id(limit_param(DEFAULT_ACCOUNTS_LIMIT), params[:max_id], params[:since_id])
    end
  end

  def list_accounts
    Account.find(account_ids)
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
