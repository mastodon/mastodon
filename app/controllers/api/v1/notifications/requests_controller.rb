# frozen_string_literal: true

class Api::V1::Notifications::RequestsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:notifications' }, only: :index
  before_action -> { doorkeeper_authorize! :write, :'write:notifications' }, except: :index

  before_action :require_user!
  before_action :set_request, except: :index

  after_action :insert_pagination_headers, only: :index

  def index
    with_read_replica do
      @requests = load_requests
      @relationships = relationships
    end

    render json: @requests, each_serializer: REST::NotificationRequestSerializer, relationships: @relationships
  end

  def show
    render json: @request, serializer: REST::NotificationRequestSerializer
  end

  def accept
    AcceptNotificationRequestService.new.call(@request)
    render_empty
  end

  def dismiss
    @request.update!(dismissed: true)
    render_empty
  end

  private

  def load_requests
    requests = NotificationRequest.where(account: current_account).where(dismissed: truthy_param?(:dismissed) || false).includes(:last_status, from_account: [:account_stat, :user]).to_a_paginated_by_id(
      limit_param(DEFAULT_ACCOUNTS_LIMIT),
      params_slice(:max_id, :since_id, :min_id)
    )

    NotificationRequest.preload_cache_collection(requests) do |statuses|
      cache_collection(statuses, Status)
    end
  end

  def relationships
    StatusRelationshipsPresenter.new(@requests.map(&:last_status), current_user&.account_id)
  end

  def set_request
    @request = NotificationRequest.where(account: current_account).find(params[:id])
  end

  def next_path
    api_v1_notifications_requests_url pagination_params(max_id: pagination_max_id) unless @requests.empty?
  end

  def prev_path
    api_v1_notifications_requests_url pagination_params(min_id: pagination_since_id) unless @requests.empty?
  end

  def pagination_max_id
    @requests.last.id
  end

  def pagination_since_id
    @requests.first.id
  end

  def pagination_params(core_params)
    params.slice(:dismissed).permit(:dismissed).merge(core_params)
  end
end
