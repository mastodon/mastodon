# frozen_string_literal: true

class SendPushNotificationService < BaseService
  def call(notification)
  	return if ENV['FCM_API_KEY'].blank?

  	devices = Device.where(account: notification.account).pluck(:registration_id)
  	fcm     = FCM.new(ENV['FCM_API_KEY'])

  	response = fcm.send(devices, data: { notification_id: notification.id }, collapse_key: :notifications, priority: :high)
  	handle_response(response)
  end

  private

  def handle_response(response)
    update_canonical_ids(response[:canonical_ids]) if response[:canonical_ids]
    remove_bad_ids(response[:not_registered_ids])  if response[:not_registered_ids]
  end

  def update_canonical_ids(ids)
  	ids.each { |pair| Device.find_by(registration_id: pair[:old]).update(registration_id: pair[:new]) }
  end

  def remove_bad_ids(bad_ids)
  	Device.where(registration_id: bad_ids).delete_all
  end
end
