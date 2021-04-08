require 'rails_helper'

describe ActivityPub::MoveDistributionWorker do
  subject { described_class.new }

  let(:migration)   { Fabricate(:account_migration) }
  let(:follower) { Fabricate(:account, protocol: :activitypub, inbox_url: 'http://example.com') }
  let(:blocker) { Fabricate(:account, protocol: :activitypub, inbox_url: 'http://example2.com') }

  describe '#perform' do
    before do
      allow(ActivityPub::DeliveryWorker).to receive(:push_bulk)
      follower.follow!(migration.account)
      blocker.block!(migration.account)
    end

    it 'delivers to followers and known blockers' do
      subject.perform(migration.id)
        expect(ActivityPub::DeliveryWorker).to have_received(:push_bulk).with(['http://example.com', 'http://example2.com'])
    end
  end
end
