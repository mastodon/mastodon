# frozen_string_literal: true

class Api::V2::Filters::AccountsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:filters' }, only: [:index, :show]
  before_action -> { doorkeeper_authorize! :write, :'write:filters' }, except: [:index, :show]
  before_action :require_user!

  before_action :set_account_filters, only: :index
  before_action :set_account_filter, only: [:show, :destroy]

  def index
    render json: @account_filters, each_serializer: REST::FilterAccountSerializer
  end

  def show
    render json: @account_filter, serializer: REST::FilterAccountSerializer
  end

  def create
    @account_filter = current_account.custom_filters.find(params[:filter_id]).accounts.create!(resource_params)

    render json: @account_filter, serializer: REST::FilterAccountSerializer
  end

  def destroy
    @account_filter.destroy!
    render_empty
  end

  private

  def set_account_filters
    filter = current_account.custom_filters.includes(:accounts).find(params[:filter_id])
    @account_filters = filter.accounts
  end

  def set_account_filter
    @account_filter = CustomFilterAccount.includes(:custom_filter).where(custom_filter: { account: current_account }).find(params[:id])
  end

  def resource_params
    params.permit(:target_account_id)
  end
end
