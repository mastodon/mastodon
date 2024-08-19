# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AcceptNotificationRequestService do
  subject { described_class.new }

  let(:notification_request) { Fabricate(:notification_request) }

  describe '#call' do
    it 'destroys the notification request, creates a permission, and queues a worker' do
      expect { subject.call(notification_request) }
        .to change { NotificationRequest.exists?(notification_request.id) }.to(false)
        .and change { NotificationPermission.exists?(account_id: notification_request.account_id, from_account_id: notification_request.from_account_id) }.to(true)

      expect(UnfilterNotificationsWorker).to have_enqueued_sidekiq_job(notification_request.account_id, notification_request.from_account_id)
    end
  end
end
