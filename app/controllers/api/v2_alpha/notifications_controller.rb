# frozen_string_literal: true

class Api::V2Alpha::NotificationsController < Api::BaseController
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
      @group_metadata = load_group_metadata
      @grouped_notifications = load_grouped_notifications
      @relationships = StatusRelationshipsPresenter.new(target_statuses_from_notifications, current_user&.account_id)
      @presenter = GroupedNotificationsPresenter.new(@grouped_notifications, expand_accounts: expand_accounts_param)

      # Preload associations to avoid N+1s
      ActiveRecord::Associations::Preloader.new(records: @presenter.accounts, associations: [:account_stat, { user: :role }]).call
    end

    MastodonOTELTracer.in_span('Api::V2Alpha::NotificationsController#index rendering') do |span|
      statuses = @grouped_notifications.filter_map { |group| group.target_status&.id }

      span.add_attributes(
        'app.notification_grouping.count' => @grouped_notifications.size,
        'app.notification_grouping.account.count' => @presenter.accounts.size,
        'app.notification_grouping.partial_account.count' => @presenter.partial_accounts.size,
        'app.notification_grouping.status.count' => statuses.size,
        'app.notification_grouping.status.unique_count' => statuses.uniq.size,
        'app.notification_grouping.expand_accounts_param' => expand_accounts_param
      )

      render json: @presenter, serializer: REST::DedupNotificationGroupSerializer, relationships: @relationships, group_metadata: @group_metadata, expand_accounts: expand_accounts_param
    end
  end

  def unread_count
    limit = limit_param(DEFAULT_NOTIFICATIONS_COUNT_LIMIT, MAX_NOTIFICATIONS_COUNT_LIMIT)

    with_read_replica do
      render json: { count: browserable_account_notifications.paginate_groups_by_min_id(limit, min_id: notification_marker&.last_read_id).count }
    end
  end

  def show
    @notification = current_account.notifications.without_suspended.find_by!(group_key: params[:id])
    presenter = GroupedNotificationsPresenter.new([NotificationGroup.from_notification(@notification)])
    render json: presenter, serializer: REST::DedupNotificationGroupSerializer
  end

  def clear
    current_account.notifications.delete_all
    render_empty
  end

  def dismiss
    current_account.notifications.where(group_key: params[:id]).destroy_all
    render_empty
  end

  private

  def load_notifications
    MastodonOTELTracer.in_span('Api::V2Alpha::NotificationsController#load_notifications') do
      notifications = browserable_account_notifications.includes(from_account: [:account_stat, :user]).to_a_grouped_paginated_by_id(
        limit_param(DEFAULT_NOTIFICATIONS_LIMIT),
        params_slice(:max_id, :since_id, :min_id)
      )

      Notification.preload_cache_collection_target_statuses(notifications) do |target_statuses|
        preload_collection(target_statuses, Status)
      end
    end
  end

  def load_group_metadata
    return {} if @notifications.empty?

    MastodonOTELTracer.in_span('Api::V2Alpha::NotificationsController#load_group_metadata') do
      browserable_account_notifications
        .where(group_key: @notifications.filter_map(&:group_key))
        .where(id: (@notifications.last.id)..(@notifications.first.id))
        .group(:group_key)
        .pluck(:group_key, 'min(notifications.id) as min_id', 'max(notifications.id) as max_id', 'max(notifications.created_at) as latest_notification_at')
        .to_h { |group_key, min_id, max_id, latest_notification_at| [group_key, { min_id: min_id, max_id: max_id, latest_notification_at: latest_notification_at }] }
    end
  end

  def load_grouped_notifications
    MastodonOTELTracer.in_span('Api::V2Alpha::NotificationsController#load_grouped_notifications') do
      @notifications.map { |notification| NotificationGroup.from_notification(notification, max_id: @group_metadata.dig(notification.group_key, :max_id)) }
    end
  end

  def browserable_account_notifications
    current_account.notifications.without_suspended.browserable(
      types: Array(browserable_params[:types]),
      exclude_types: Array(browserable_params[:exclude_types]),
      include_filtered: truthy_param?(:include_filtered)
    )
  end

  def notification_marker
    current_user.markers.find_by(timeline: 'notifications')
  end

  def target_statuses_from_notifications
    @notifications.filter_map(&:target_status)
  end

  def next_path
    api_v2_alpha_notifications_url pagination_params(max_id: pagination_max_id) unless @notifications.empty?
  end

  def prev_path
    api_v2_alpha_notifications_url pagination_params(min_id: pagination_since_id) unless @notifications.empty?
  end

  def pagination_collection
    @notifications
  end

  def browserable_params
    params.permit(:include_filtered, types: [], exclude_types: [])
  end

  def pagination_params(core_params)
    params.slice(:limit, :types, :exclude_types, :include_filtered).permit(:limit, :include_filtered, types: [], exclude_types: []).merge(core_params)
  end

  def expand_accounts_param
    case params[:expand_accounts]
    when nil, 'full'
      'full'
    when 'partial_avatars'
      'partial_avatars'
    else
      raise Mastodon::InvalidParameterError, "Invalid value for 'expand_accounts': '#{params[:expand_accounts]}', allowed values are 'full' and 'partial_avatars'"
    end
  end
end
