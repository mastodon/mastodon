require 'rails_helper'

describe ActivityPub::StatusUpdateDistributionWorker do
  subject { described_class.new }

  let(:status)   { Fabricate(:status, text: 'foo') }
  let(:follower) { Fabricate(:account, protocol: :activitypub, inbox_url: 'http://example.com') }

  let(:delivery_stub) { double }

  describe '#perform' do
    before do
      allow(ActivityPub::DeliveryWorker).to receive(:new).and_return(delivery_stub)
      allow(delivery_stub).to receive(:perform)

      follower.follow!(status.account)

      status.snapshot!
      status.text = 'bar'
      status.edited_at = Time.now.utc
      status.snapshot!
      status.save!
    end

    context 'with public status' do
      before do
        status.update(visibility: :public)
      end

      it 'delivers to followers' do
        subject.perform(status.id)
        expect(delivery_stub).to have_received(:perform).with(kind_of(Hash), status.account.id, 'http://example.com', anything)
      end
    end

    context 'with private status' do
      before do
        status.update(visibility: :private)
      end

      it 'delivers to followers' do
        subject.perform(status.id)
        expect(delivery_stub).to have_received(:perform).with(kind_of(Hash), status.account.id, 'http://example.com', anything)
      end
    end
  end
end
