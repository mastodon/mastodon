# frozen_string_literal: true

class AcceptNotificationRequestService < BaseService
  include Redisable

  def call(request)
    NotificationPermission.create!(account: request.account, from_account: request.from_account)
    increment_worker_count!(request)
    UnfilterNotificationsWorker.perform_async(request.account_id, request.from_account_id)
    request.destroy!
  end

  private

  def increment_worker_count!(request)
    with_redis do |redis|
      redis.incr("notification_unfilter_jobs:#{request.account_id}")
      redis.expire("notification_unfilter_jobs:#{request.account_id}", 30.minutes.to_i)
    end
  end
end
