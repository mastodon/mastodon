require 'rails_helper'

describe ActivityPub::DistributionWorker do
  subject { described_class.new }

  let(:status)   { Fabricate(:status) }
  let(:follower) { Fabricate(:account, protocol: :activitypub, inbox_url: 'http://example.com') }

  describe '#perform' do
    before do
      allow(ActivityPub::DeliveryWorker).to receive(:push_bulk)
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
        expect(ActivityPub::DeliveryWorker).to have_received(:push_bulk).with(['http://example.com'])
      end
    end

    context 'with direct status' do
      let(:mentioned_account) { Fabricate(:account, protocol: :activitypub, inbox_url: 'https://foo.bar/inbox')}

      before do
        status.update(visibility: :direct)
        status.mentions.create!(account: mentioned_account)
      end

      it 'delivers to mentioned accounts' do
        subject.perform(status.id)
        expect(ActivityPub::DeliveryWorker).to have_received(:push_bulk).with(['https://foo.bar/inbox'])
      end
    end
  end
end
