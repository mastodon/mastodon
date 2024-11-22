# frozen_string_literal: true

class Api::V1::NotificationsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:notifications' }, except: [:clear, :dismiss]
  before_action -> { doorkeeper_authorize! :write, :'write:notifications' }, only: [:clear, :dismiss]
  before_action :require_user!
  after_action :insert_pagination_headers, only: :index

  DEFAULT_NOTIFICATIONS_LIMIT = 40
  DEFAULT_NOTIFICATIONS_COUNT_LIMIT = 100
  MAX_NOTIFICATIONS_COUNT_LIMIT = 1_000

  def index
    with_read_replica do
      @notifications = load_notifications
      @relationships = StatusRelationshipsPresenter.new(target_statuses_from_notifications, current_user&.account_id)
    end

    render json: @notifications, each_serializer: REST::NotificationSerializer, relationships: @relationships
  end

  def unread_count
    limit = limit_param(DEFAULT_NOTIFICATIONS_COUNT_LIMIT, MAX_NOTIFICATIONS_COUNT_LIMIT)

    with_read_replica do
      render json: { count: browserable_account_notifications.paginate_by_min_id(limit, notification_marker&.last_read_id).count }
    end
  end

  def show
    @notification = current_account.notifications.without_suspended.find(params[:id])
    render json: @notification, serializer: REST::NotificationSerializer
  end

  def clear
    current_account.notifications.delete_all
    render_empty
  end

  def dismiss
    current_account.notifications.find(params[:id]).destroy!
    render_empty
  end

  private

  def load_notifications
    notifications = browserable_account_notifications.includes(from_account: [:account_stat, :user]).to_a_paginated_by_id(
      limit_param(DEFAULT_NOTIFICATIONS_LIMIT),
      params_slice(:max_id, :since_id, :min_id)
    )

    Notification.preload_cache_collection_target_statuses(notifications) do |target_statuses|
      preload_collection(target_statuses, Status)
    end
  end

  def browserable_account_notifications
    current_account.notifications.without_suspended.browserable(
      types: Array(browserable_params[:types]),
      exclude_types: Array(browserable_params[:exclude_types]),
      from_account_id: browserable_params[:account_id],
      include_filtered: truthy_param?(:include_filtered)
    )
  end

  def notification_marker
    current_user.markers.find_by(timeline: 'notifications')
  end

  def target_statuses_from_notifications
    @notifications.reject { |notification| notification.target_status.nil? }.map(&:target_status)
  end

  def next_path
    api_v1_notifications_url pagination_params(max_id: pagination_max_id) unless @notifications.empty?
  end

  def prev_path
    api_v1_notifications_url pagination_params(min_id: pagination_since_id) unless @notifications.empty?
  end

  def pagination_collection
    @notifications
  end

  def browserable_params
    params.permit(:account_id, :include_filtered, types: [], exclude_types: [])
  end

  def pagination_params(core_params)
    params.slice(:limit, :account_id, :types, :exclude_types, :include_filtered).permit(:limit, :account_id, :include_filtered, types: [], exclude_types: []).merge(core_params)
  end
end
