require 'rails_helper'

describe ActivityPub::DistributePollUpdateWorker do
  subject { described_class.new }

  let(:account)  { Fabricate(:account) }
  let(:follower) { Fabricate(:account, protocol: :activitypub, inbox_url: 'http://example.com') }
  let(:poll)     { Fabricate(:poll, account: account) }
  let!(:status)  { Fabricate(:status, account: account, poll: poll) }

  describe '#perform' do
    before do
      allow(ActivityPub::DeliveryWorker).to receive(:push_bulk)
      follower.follow!(account)
    end

    it 'delivers to followers' do
      subject.perform(status.id)
      expect(ActivityPub::DeliveryWorker).to have_received(:push_bulk).with(['http://example.com'])
    end
  end
end
