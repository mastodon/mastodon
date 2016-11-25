# frozen_string_literal: true

class Api::V1::NotificationsController < ApiController
  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!

  respond_to :json

  def index
    @notifications = Notification.where(account: current_account).paginate_by_max_id(20, params[:max_id], params[:since_id])
    @notifications = cache(@notifications)
    statuses       = @notifications.select { |n| !n.target_status.nil? }.map(&:target_status)

    set_maps(statuses)
    set_counters_maps(statuses)
    set_account_counters_maps(@notifications.map(&:from_account))

    next_path = api_v1_notifications_url(max_id: @notifications.last.id)    if @notifications.size == 20
    prev_path = api_v1_notifications_url(since_id: @notifications.first.id) unless @notifications.empty?

    set_pagination_headers(next_path, prev_path)
  end

  private

  def cache(raw)
    uncached_ids           = []
    cached_keys_with_value = Rails.cache.read_multi(*raw.map(&:cache_key))

    raw.each do |notification|
      uncached_ids << notification.id unless cached_keys_with_value.key?(notification.cache_key)
    end

    unless uncached_ids.empty?
      uncached = Notification.where(id: uncached_ids).with_includes.map { |n| [n.id, n] }.to_h

      uncached.values.each do |notification|
        Rails.cache.write(notification.cache_key, notification)
      end
    end

    raw.map { |notification| cached_keys_with_value[notification.cache_key] || uncached[notification.id] }.compact
  end
end
