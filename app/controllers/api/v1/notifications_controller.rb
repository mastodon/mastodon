# frozen_string_literal: true

class Api::V1::NotificationsController < ApiController
  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!

  respond_to :json

  DEFAULT_NOTIFICATIONS_LIMIT = 15

  def index
    @notifications = Notification.where(account: current_account).browserable(exclude_types).paginate_by_max_id(limit_param(DEFAULT_NOTIFICATIONS_LIMIT), params[:max_id], params[:since_id])
    @notifications = cache_collection(@notifications, Notification)
    statuses       = @notifications.select { |n| !n.target_status.nil? }.map(&:target_status)

    set_maps(statuses)

    next_path = api_v1_notifications_url(pagination_params(max_id: @notifications.last.id))    unless @notifications.empty?
    prev_path = api_v1_notifications_url(pagination_params(since_id: @notifications.first.id)) unless @notifications.empty?

    set_pagination_headers(next_path, prev_path)
  end

  def show
    @notification = Notification.where(account: current_account).find(params[:id])
  end

  def clear
    Notification.where(account: current_account).delete_all
    render_empty
  end

  private

  def exclude_types
    val = params.permit(exclude_types: [])[:exclude_types] || []
    val = [val] unless val.is_a?(Enumerable)
    val
  end

  def pagination_params(core_params)
    params.permit(:limit, exclude_types: []).merge(core_params)
  end
end
