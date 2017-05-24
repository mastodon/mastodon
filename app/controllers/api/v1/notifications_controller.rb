# frozen_string_literal: true

class Api::V1::NotificationsController < ApiController
  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!
  after_action :insert_pagination_headers, only: :index

  respond_to :json

  DEFAULT_NOTIFICATIONS_LIMIT = 15

  def index
    @notifications = load_notifications
    set_maps_for_notification_target_statuses
  end

  def show
    @notification = current_account.notifications.find(params[:id])
  end

  def clear
    current_account.notifications.delete_all
    render_empty
  end

  def dismiss
    current_account.notifications.find_by!(id: params[:id]).destroy!
    render_empty
  end

  private

  def load_notifications
    cache_collection paginated_notifications, Notification
  end

  def paginated_notifications
    browserable_account_notifications.paginate_by_max_id(
      limit_param(DEFAULT_NOTIFICATIONS_LIMIT),
      params[:max_id],
      params[:since_id]
    )
  end

  def browserable_account_notifications
    current_account.notifications.browserable(exclude_types)
  end

  def set_maps_for_notification_target_statuses
    set_maps target_statuses_from_notifications
  end

  def target_statuses_from_notifications
    @notifications.select { |notification| !notification.target_status.nil? }.map(&:target_status)
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def next_path
    unless @notifications.empty?
      api_v1_notifications_url pagination_params(max_id: pagination_max_id)
    end
  end

  def prev_path
    unless @notifications.empty?
      api_v1_notifications_url pagination_params(since_id: pagination_since_id)
    end
  end

  def pagination_max_id
    @notifications.last.id
  end

  def pagination_since_id
    @notifications.first.id
  end

  def exclude_types
    val = params.permit(exclude_types: [])[:exclude_types] || []
    val = [val] unless val.is_a?(Enumerable)
    val
  end

  def pagination_params(core_params)
    params.permit(:limit, exclude_types: []).merge(core_params)
  end
end
