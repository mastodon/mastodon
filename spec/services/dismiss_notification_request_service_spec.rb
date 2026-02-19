# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DismissNotificationRequestService do
  describe '#call' do
    let(:sender) { Fabricate(:account) }
    let(:receiver) { Fabricate(:account) }
    let(:request) { Fabricate(:notification_request, account: receiver, from_account: sender) }

    it 'destroys the request and queues a worker', :aggregate_failures do
      expect { described_class.new.call(request) }
        .to change(request, :destroyed?).to(true)

      expect(FilteredNotificationCleanupWorker)
        .to have_enqueued_sidekiq_job(receiver.id, sender.id)
    end
  end
end
