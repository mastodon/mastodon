require 'rails_helper'

describe ActivityPub::UpdateDistributionWorker do
  subject { described_class.new }

  let(:account)  { Fabricate(:account) }
  let(:follower) { Fabricate(:account, protocol: :activitypub, inbox_url: 'http://example.com') }

  describe '#perform' do
    before do
      allow(ActivityPub::DeliveryWorker).to receive(:push_bulk)
      follower.follow!(account)
    end

    it 'delivers to followers' do
      subject.perform(account.id)
      expect(ActivityPub::DeliveryWorker).to have_received(:push_bulk).with(['http://example.com'])
    end
  end
end
