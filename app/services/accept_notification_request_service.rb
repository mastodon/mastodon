# frozen_string_literal: true

class AcceptNotificationRequestService < BaseService
  def call(request)
    NotificationPermission.create!(account: request.account, from_account: request.from_account)
    UnfilterNotificationsWorker.perform_async(request.id)
  end
end
