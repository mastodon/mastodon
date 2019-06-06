# frozen_string_literal: true

class Api::V1::ScheduledStatusesController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :read, :'read:statuses' }, except: [:update, :destroy]
  before_action -> { doorkeeper_authorize! :write, :'write:statuses' }, only: [:update, :destroy]

  before_action :set_statuses, only: :index
  before_action :set_status, except: :index

  after_action :insert_pagination_headers, only: :index

  def index
    render json: @statuses, each_serializer: REST::ScheduledStatusSerializer
  end

  def show
    render json: @status, serializer: REST::ScheduledStatusSerializer
  end

  def update
    @status.update!(scheduled_status_params)
    render json: @status, serializer: REST::ScheduledStatusSerializer
  end

  def destroy
    @status.destroy!
    render_empty
  end

  private

  def set_statuses
    @statuses = current_account.scheduled_statuses.paginate_by_id(limit_param(DEFAULT_STATUSES_LIMIT), params_slice(:max_id, :since_id, :min_id))
  end

  def set_status
    @status = current_account.scheduled_statuses.find(params[:id])
  end

  def scheduled_status_params
    params.permit(:scheduled_at)
  end

  def pagination_params(core_params)
    params.slice(:limit).permit(:limit).merge(core_params)
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def next_path
    if records_continue?
      api_v1_scheduled_statuses_url pagination_params(max_id: pagination_max_id)
    end
  end

  def prev_path
    unless @statuses.empty?
      api_v1_scheduled_statuses_url pagination_params(min_id: pagination_since_id)
    end
  end

  def records_continue?
    @statuses.size == limit_param(DEFAULT_STATUSES_LIMIT)
  end

  def pagination_max_id
    @statuses.last.id
  end

  def pagination_since_id
    @statuses.first.id
  end
end
