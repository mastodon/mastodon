# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnfilterNotificationsWorker do
  let(:recipient) { Fabricate(:account) }
  let(:sender) { Fabricate(:account) }
  let(:worker) { described_class.new }

  before do
    # Populate multiple kinds of filtered notifications
    private_message = Fabricate(:status, account: sender, visibility: :direct)
    mention = Fabricate(:mention, account: recipient, status: private_message)
    Fabricate(:notification, filtered: true, from_account: sender, account: recipient, type: :mention, activity: mention)
    follow_request = sender.request_follow!(recipient)
    Fabricate(:notification, filtered: true, from_account: sender, account: recipient, type: :follow_request, activity: follow_request)
    allow(redis).to receive(:publish)
    allow(redis).to receive(:exists?).and_return(false)
  end

  shared_examples 'shared behavior' do
    context 'when this is the last pending merge job and the user is subscribed to streaming' do
      before do
        redis.set("notification_unfilter_jobs:#{recipient.id}", 1)
        allow(redis).to receive(:exists?).with("subscribed:timeline:#{recipient.id}").and_return(true)
      end

      it 'unfilters notifications, adds private messages to conversations, and pushes to redis' do
        expect { subject }
          .to change { recipient.notifications.where(from_account_id: sender.id).pluck(:filtered) }.from([true, true]).to([false, false])
          .and change { recipient.conversations.exists?(last_status_id: sender.statuses.first.id) }.to(true)
          .and change { redis.get("notification_unfilter_jobs:#{recipient.id}").to_i }.by(-1)

        expect(redis).to have_received(:publish).with("timeline:#{recipient.id}:notifications", '{"event":"notifications_merged","payload":"1"}')
      end
    end

    context 'when this is not last pending merge job and the user is subscribed to streaming' do
      before do
        redis.set("notification_unfilter_jobs:#{recipient.id}", 2)
        allow(redis).to receive(:exists?).with("subscribed:timeline:#{recipient.id}").and_return(true)
      end

      it 'unfilters notifications, adds private messages to conversations, and does not push to redis' do
        expect { subject }
          .to change { recipient.notifications.where(from_account_id: sender.id).pluck(:filtered) }.from([true, true]).to([false, false])
          .and change { recipient.conversations.exists?(last_status_id: sender.statuses.first.id) }.to(true)
          .and change { redis.get("notification_unfilter_jobs:#{recipient.id}").to_i }.by(-1)

        expect(redis).to_not have_received(:publish).with("timeline:#{recipient.id}:notifications", '{"event":"notifications_merged","payload":"1"}')
      end
    end

    context 'when this is the last pending merge job and the user is not subscribed to streaming' do
      before do
        redis.set("notification_unfilter_jobs:#{recipient.id}", 1)
      end

      it 'unfilters notifications, adds private messages to conversations, and does not push to redis' do
        expect { subject }
          .to change { recipient.notifications.where(from_account_id: sender.id).pluck(:filtered) }.from([true, true]).to([false, false])
          .and change { recipient.conversations.exists?(last_status_id: sender.statuses.first.id) }.to(true)
          .and change { redis.get("notification_unfilter_jobs:#{recipient.id}").to_i }.by(-1)

        expect(redis).to_not have_received(:publish).with("timeline:#{recipient.id}:notifications", '{"event":"notifications_merged","payload":"1"}')
      end
    end
  end

  describe '#perform' do
    context 'with recipient and sender' do
      subject { worker.perform(recipient.id, sender.id) }

      it_behaves_like 'shared behavior'
    end

    context 'with missing records' do
      it 'runs without error for missing sender' do
        expect { worker.perform(recipient.id, nil) }
          .to_not raise_error
      end

      it 'runs without error for missing recipient' do
        expect { worker.perform(nil, sender.id) }
          .to_not raise_error
      end
    end
  end
end
