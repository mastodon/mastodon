require 'rails_helper'

describe ActivityPub::MoveDistributionWorker do
  subject { described_class.new }

  let(:migration) { Fabricate(:account_migration) }
  let(:follower) { Fabricate(:account, protocol: :activitypub, inbox_url: 'http://example.com') }
  let(:blocker) { Fabricate(:account, protocol: :activitypub, inbox_url: 'http://example2.com') }

  describe '#perform' do
    before do
      follower.follow!(migration.account)
      blocker.block!(migration.account)
    end

    it 'delivers to followers and known blockers' do
      expect_push_bulk_to_match(ActivityPub::DeliveryWorker, [
                                  [kind_of(String), migration.account.id, 'http://example.com'],
                                  [kind_of(String), migration.account.id, 'http://example2.com'],
                                ])
      subject.perform(migration.id)
    end
  end
end
