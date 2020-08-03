require 'rails_helper'

describe ActivityPub::DistributionWorker do
  include RoutingHelper

  subject { described_class.new }

  let(:status)   { Fabricate(:status) }
  let(:follower) { Fabricate(:account, protocol: :activitypub, inbox_url: 'http://example.com', domain: 'example.com', uri: 'http://example.com/follower') }

  let(:delivery_worker) { double }

  describe '#perform' do
    before do
      allow(delivery_worker).to receive(:perform)

      allow(ActivityPub::DeliveryWorker).to receive(:push_bulk) do |items, &block|
        items = items.map(&block) if block
        items.each { |args| delivery_worker.perform(*args) }
      end

      follower.follow!(status.account)
    end

    context 'with public status' do
      before do
        status.update(visibility: :public)
      end

      it 'delivers to followers' do
        subject.perform(status.id)
        expect(ActivityPub::DeliveryWorker).to have_received(:push_bulk).with(['http://example.com'])
      end
    end

    context 'with private status' do
      before do
        status.update(visibility: :private)
      end

      it 'delivers to followers' do
        subject.perform(status.id)
        expect(ActivityPub::DeliveryWorker).to have_received(:push_bulk).with([['http://example.com', 'example.com']])
      end

      it 'sets synchronizeCollection attribute' do
        subject.perform(status.id)

        expect(delivery_worker).to have_received(:perform) do |json, source_account_id, inbox_url|
          expect(source_account_id).to eq status.account.id
          expect(inbox_url).to eq follower.inbox_url

          json = Oj.load(json, mode: :strict)

          expect(json['collectionSynchronization'][0]).to eq({
            type: 'SynchronizationItem',
            domain: 'example.com',
            object: account_followers_url(status.account),
            partialCollection: account_followers_synchronization_url(status.account),
            digest: {
              type: 'Digest',
              digestAlgorithm: 'http://www.w3.org/2001/04/xmlenc#sha256',
              digestValue: '80bcd0bb7a348b3ddcb6ba1a3b53d585ccb80659c39dee5e2a112037da7d37bc',
            },
          }.with_indifferent_access)
        end
      end
    end

    context 'with direct status' do
      before do
        status.update(visibility: :direct)
      end

      it 'does nothing' do
        subject.perform(status.id)
        expect(ActivityPub::DeliveryWorker).to_not have_received(:push_bulk)
      end
    end
  end
end
