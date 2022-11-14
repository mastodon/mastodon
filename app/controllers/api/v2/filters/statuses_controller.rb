# frozen_string_literal: true

class Api::V2::Filters::StatusesController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:filters' }, only: [:index, :show]
  before_action -> { doorkeeper_authorize! :write, :'write:filters' }, except: [:index, :show]
  before_action :require_user!

  before_action :set_status_filters, only: :index
  before_action :set_status_filter, only: [:show, :destroy]

  def index
    render json: @status_filters, each_serializer: REST::FilterStatusSerializer
  end

  def create
    @status_filter = current_account.custom_filters.find(params[:filter_id]).statuses.create!(resource_params)

    render json: @status_filter, serializer: REST::FilterStatusSerializer
  end

  def show
    render json: @status_filter, serializer: REST::FilterStatusSerializer
  end

  def destroy
    @status_filter.destroy!
    render_empty
  end

  private

  def set_status_filters
    filter = current_account.custom_filters.includes(:statuses).find(params[:filter_id])
    @status_filters = filter.statuses
  end

  def set_status_filter
    @status_filter = CustomFilterStatus.includes(:custom_filter).where(custom_filter: { account: current_account }).find(params[:id])
  end

  def resource_params
    params.permit(:status_id)
  end
end
