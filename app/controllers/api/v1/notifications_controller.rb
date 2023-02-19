# frozen_string_literal: true

class Api::V1::NotificationsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:notifications' }, except: [:clear, :dismiss, :destroy, :destroy_multiple]
  before_action -> { doorkeeper_authorize! :write, :'write:notifications' }, only: [:clear, :dismiss, :destroy, :destroy_multiple]
  before_action :require_user!
  after_action :insert_pagination_headers, only: :index

  DEFAULT_NOTIFICATIONS_LIMIT = 40

  def index
    @notifications = load_notifications
    render json: @notifications, each_serializer: REST::NotificationSerializer, relationships: StatusRelationshipsPresenter.new(target_statuses_from_notifications, current_user&.account_id)
  end

  def show
    @notification = current_account.notifications.without_suspended.find(params[:id])
    render json: @notification, serializer: REST::NotificationSerializer
  end

  def clear
    current_account.notifications.delete_all
    render_empty
  end

  def destroy
    dismiss
  end

  def dismiss
    current_account.notifications.find_by!(id: params[:id]).destroy!
    render_empty
  end

  def destroy_multiple
    current_account.notifications.where(id: params[:ids]).destroy_all
    render_empty
  end

  private

  def load_notifications
    notifications = browserable_account_notifications.includes(from_account: [:account_stat, :user]).to_a_paginated_by_id(
      limit_param(DEFAULT_NOTIFICATIONS_LIMIT),
      params_slice(:max_id, :since_id, :min_id)
    )

    Notification.preload_cache_collection_target_statuses(notifications) do |target_statuses|
      cache_collection(target_statuses, Status)
    end
  end

  def browserable_account_notifications
    current_account.notifications.without_suspended.browserable(
      types: Array(browserable_params[:types]),
      exclude_types: Array(browserable_params[:exclude_types]),
      from_account_id: browserable_params[:account_id]
    )
  end

  def target_statuses_from_notifications
    @notifications.reject { |notification| notification.target_status.nil? }.map(&:target_status)
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def next_path
    api_v1_notifications_url pagination_params(max_id: pagination_max_id) unless @notifications.empty?
  end

  def prev_path
    api_v1_notifications_url pagination_params(min_id: pagination_since_id) unless @notifications.empty?
  end

  def pagination_max_id
    @notifications.last.id
  end

  def pagination_since_id
    @notifications.first.id
  end

  def browserable_params
    params.permit(:account_id, types: [], exclude_types: [])
  end

  def pagination_params(core_params)
    params.slice(:limit, :account_id, :types, :exclude_types).permit(:limit, :account_id, types: [], exclude_types: []).merge(core_params)
  end
end
