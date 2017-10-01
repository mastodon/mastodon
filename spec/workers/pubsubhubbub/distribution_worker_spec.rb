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
      allow(Pubsubhubbub::DeliveryWorker).to receive(:push_bulk)
      subject.perform(status.stream_entry.id)
      expect(Pubsubhubbub::DeliveryWorker).to have_received(:push_bulk).with([anonymous_subscription, subscription_with_follower])
    end
  end

  context 'when OStatus privacy is used' do
    around do |example|
      before_val = Rails.configuration.x.use_ostatus_privacy
      Rails.configuration.x.use_ostatus_privacy = true
      example.run
      Rails.configuration.x.use_ostatus_privacy = before_val
    end

    describe 'with private status' do
      let(:status) { Fabricate(:status, account: alice, text: 'Hello', visibility: :private) }

      it 'delivers payload only to subscriptions with followers' do
        allow(Pubsubhubbub::DeliveryWorker).to receive(:push_bulk)
        subject.perform(status.stream_entry.id)
        expect(Pubsubhubbub::DeliveryWorker).to have_received(:push_bulk).with([subscription_with_follower])
        expect(Pubsubhubbub::DeliveryWorker).to_not have_received(:push_bulk).with([anonymous_subscription])
      end
    end

    describe 'with direct status' do
      let(:status) { Fabricate(:status, account: alice, text: 'Hello', visibility: :direct) }

      it 'does not deliver payload' do
        allow(Pubsubhubbub::DeliveryWorker).to receive(:push_bulk)
        subject.perform(status.stream_entry.id)
        expect(Pubsubhubbub::DeliveryWorker).to_not have_received(:push_bulk)
      end
    end
  end

  context 'when OStatus privacy is not used' do
    around do |example|
      before_val = Rails.configuration.x.use_ostatus_privacy
      Rails.configuration.x.use_ostatus_privacy = false
      example.run
      Rails.configuration.x.use_ostatus_privacy = before_val
    end

    describe 'with private status' do
      let(:status) { Fabricate(:status, account: alice, text: 'Hello', visibility: :private) }

      it 'does not deliver anything' do
        allow(Pubsubhubbub::DeliveryWorker).to receive(:push_bulk)
        subject.perform(status.stream_entry.id)
        expect(Pubsubhubbub::DeliveryWorker).to_not have_received(:push_bulk)
      end
    end

    describe 'with direct status' do
      let(:status) { Fabricate(:status, account: alice, text: 'Hello', visibility: :direct) }

      it 'does not deliver payload' do
        allow(Pubsubhubbub::DeliveryWorker).to receive(:push_bulk)
        subject.perform(status.stream_entry.id)
        expect(Pubsubhubbub::DeliveryWorker).to_not have_received(:push_bulk)
      end
    end
  end
end
