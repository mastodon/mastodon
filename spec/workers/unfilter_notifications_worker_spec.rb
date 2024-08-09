# frozen_string_literal: true

require 'rails_helper'

describe UnfilterNotificationsWorker do
  let(:recipient) { Fabricate(:account) }
  let(:sender) { Fabricate(:account) }

  before do
    # Populate multiple kinds of filtered notifications
    private_message = Fabricate(:status, account: sender, visibility: :direct)
    mention = Fabricate(:mention, account: recipient, status: private_message)
    Fabricate(:notification, filtered: true, from_account: sender, account: recipient, type: :mention, activity: mention)
    follow_request = sender.request_follow!(recipient)
    Fabricate(:notification, filtered: true, from_account: sender, account: recipient, type: :follow_request, activity: follow_request)
  end

  shared_examples 'shared behavior' do
    it 'unfilters notifications and adds private messages to conversations' do
      expect { subject }
        .to change { recipient.notifications.where(from_account_id: sender.id).pluck(:filtered) }.from([true, true]).to([false, false])
        .and change { recipient.conversations.exists?(last_status_id: sender.statuses.first.id) }.to(true)
    end
  end

  describe '#perform' do
    context 'with single argument (prerelease behavior)' do
      subject { described_class.new.perform(notification_request.id) }

      let(:notification_request) { Fabricate(:notification_request, from_account: sender, account: recipient) }

      it_behaves_like 'shared behavior'

      it 'destroys the notification request' do
        expect { subject }
          .to change { NotificationRequest.exists?(notification_request.id) }.to(false)
      end
    end

    context 'with two arguments' do
      subject { described_class.new.perform(recipient.id, sender.id) }

      it_behaves_like 'shared behavior'
    end
  end
end
