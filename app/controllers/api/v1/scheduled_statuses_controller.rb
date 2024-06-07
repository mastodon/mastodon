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
    @statuses = current_account.scheduled_statuses.to_a_paginated_by_id(limit_param(DEFAULT_STATUSES_LIMIT), params_slice(:max_id, :since_id, :min_id))
  end

  def set_status
    @status = current_account.scheduled_statuses.find(params[:id])
  end

  def scheduled_status_params
    params.permit(:scheduled_at)
  end

  def next_path
    api_v1_scheduled_statuses_url pagination_params(max_id: pagination_max_id) if records_continue?
  end

  def prev_path
    api_v1_scheduled_statuses_url pagination_params(min_id: pagination_since_id) unless @statuses.empty?
  end

  def records_continue?
    @statuses.size == limit_param(DEFAULT_STATUSES_LIMIT)
  end

  def pagination_collection
    @statuses
  end
end
