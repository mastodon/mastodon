# frozen_string_literal: true

class Api::V1::NotificationsController < ApiController
  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!

  respond_to :json

  def index
    @notifications = Notification.where(account: current_account).browserable.paginate_by_max_id(20, params[:max_id], params[:since_id])
    @notifications = cache_collection(@notifications, Notification)
    statuses       = @notifications.select { |n| !n.target_status.nil? }.map(&:target_status)

    set_maps(statuses)
    set_counters_maps(statuses)
    set_account_counters_maps(@notifications.map(&:from_account))

    next_path = api_v1_notifications_url(max_id: @notifications.last.id)    if @notifications.size == 20
    prev_path = api_v1_notifications_url(since_id: @notifications.first.id) unless @notifications.empty?

    set_pagination_headers(next_path, prev_path)
  end
end
