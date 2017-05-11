require 'rails_helper'

describe Pubsubhubbub::DistributionWorker do
  subject { Pubsubhubbub::DistributionWorker.new }

  let!(:alice) { Fabricate(:account, username: 'alice') }
  let!(:bob) { Fabricate(:account, username: 'bob', domain: 'example2.com') }
  let!(:anonymous_subscription) { Fabricate(:subscription, account: alice, callback_url: 'http://example1.com', confirmed: true, lease_seconds: 3600) }
  let!(:subscription_with_follower) { Fabricate(:subscription, account: alice, callback_url: 'http://example2.com', confirmed: true, lease_seconds: 3600) }

  before do
    bob.follow!(alice)
  end

  describe 'with public status' do
    let(:status) { Fabricate(:status, account: alice, text: 'Hello', visibility: :public) }

    it 'delivers payload to all subscriptions' do
      allow(Pubsubhubbub::DeliveryWorker).to receive(:perform_async)
      subject.perform(status.stream_entry.id)
      expect(Pubsubhubbub::DeliveryWorker).to have_received(:perform_async).with(subscription_with_follower.id, /.*/)
      expect(Pubsubhubbub::DeliveryWorker).to have_received(:perform_async).with(anonymous_subscription.id, /.*/)
    end
  end

  describe 'with private status' do
    let(:status) { Fabricate(:status, account: alice, text: 'Hello', visibility: :private) }

    it 'delivers payload only to subscriptions with followers' do
      allow(Pubsubhubbub::DeliveryWorker).to receive(:perform_async)
      subject.perform(status.stream_entry.id)
      expect(Pubsubhubbub::DeliveryWorker).to have_received(:perform_async).with(subscription_with_follower.id, /.*/)
      expect(Pubsubhubbub::DeliveryWorker).to_not have_received(:perform_async).with(anonymous_subscription.id, /.*/)
    end
  end

  describe 'with direct status' do
    let(:status) { Fabricate(:status, account: alice, text: 'Hello', visibility: :direct) }

    it 'does not deliver payload' do
      allow(Pubsubhubbub::DeliveryWorker).to receive(:perform_async)
      subject.perform(status.stream_entry.id)
      expect(Pubsubhubbub::DeliveryWorker).to_not have_received(:perform_async)
    end
  end
end
