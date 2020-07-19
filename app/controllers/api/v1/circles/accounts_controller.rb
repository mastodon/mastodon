# frozen_string_literal: true

class Api::V1::Circles::AccountsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:circles' }, only: [:show]
  before_action -> { doorkeeper_authorize! :write, :'write:circles' }, except: [:show]

  before_action :require_user!
  before_action :set_circle

  after_action :insert_pagination_headers, only: :show

  def show
    @accounts = load_accounts
    render json: @accounts, each_serializer: REST::AccountSerializer
  end

  def create
    ApplicationRecord.transaction do
      circle_accounts.each do |account|
        @circle.accounts << account
      end
    end

    render_empty
  end

  def destroy
    CircleAccount.where(circle: @circle, account_id: account_ids).destroy_all
    render_empty
  end

  private

  def set_circle
    @circle = current_account.owned_circles.find(params[:circle_id])
  end

  def load_accounts
    if unlimited?
      @circle.accounts.includes(:account_stat).all
    else
      @circle.accounts.includes(:account_stat).paginate_by_max_id(limit_param(DEFAULT_ACCOUNTS_LIMIT), params[:max_id], params[:since_id])
    end
  end

  def circle_accounts
    Account.find(account_ids)
  end

  def account_ids
    Array(resource_params[:account_ids])
  end

  def resource_params
    params.permit(account_ids: [])
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def next_path
    return if unlimited?

    api_v1_circle_accounts_url(pagination_params(max_id: pagination_max_id)) if records_continue?
  end

  def prev_path
    return if unlimited?

    api_v1_circle_accounts_url(pagination_params(since_id: pagination_since_id)) unless @accounts.empty?
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
