# frozen_string_literal: true

class Api::V1::Notifications::RequestsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:notifications' }, only: :index
  before_action -> { doorkeeper_authorize! :write, :'write:notifications' }, except: :index

  before_action :require_user!
  before_action :set_request, only: [:show, :accept, :dismiss]
  before_action :set_requests, only: [:accept_bulk, :dismiss_bulk]

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
    DismissNotificationRequestService.new.call(@request)
    render_empty
  end

  def accept_bulk
    @requests.each { |request| AcceptNotificationRequestService.new.call(request) }
    render_empty
  end

  def dismiss_bulk
    @requests.each(&:destroy!)
    render_empty
  end

  private

  def load_requests
    requests = NotificationRequest.where(account: current_account).includes(:last_status, from_account: [:account_stat, :user]).to_a_paginated_by_id(
      limit_param(DEFAULT_ACCOUNTS_LIMIT),
      params_slice(:max_id, :since_id, :min_id)
    )

    NotificationRequest.preload_cache_collection(requests) do |statuses|
      preload_collection(statuses, Status)
    end
  end

  def relationships
    StatusRelationshipsPresenter.new(@requests.map(&:last_status), current_user&.account_id)
  end

  def set_request
    @request = NotificationRequest.where(account: current_account).find(params[:id])
  end

  def set_requests
    @requests = NotificationRequest.where(account: current_account, id: Array(params[:id]).uniq.map(&:to_i))
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
end
