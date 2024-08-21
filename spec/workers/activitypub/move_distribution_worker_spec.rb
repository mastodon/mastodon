# frozen_string_literal: true

require 'rails_helper'

describe ActivityPub::MoveDistributionWorker do
  subject { described_class.new }

  let(:migration) { Fabricate(:account_migration) }
  let(:follower) { Fabricate(:account, protocol: :activitypub, inbox_url: 'http://example.com', domain: 'example.com') }
  let(:blocker) { Fabricate(:account, protocol: :activitypub, inbox_url: 'http://example2.com', domain: 'example2.com') }

  describe '#perform' do
    before do
      follower.follow!(migration.account)
      blocker.block!(migration.account)
    end

    it 'delivers to followers and known blockers' do
      expect_push_bulk_to_match(ActivityPub::DeliveryWorker, expected_migration_deliveries) do
        subject.perform(migration.id)
      end
    end

    def expected_migration_deliveries
      [
        [match_json_values(type: 'Move'), migration.account.id, 'http://example.com'],
        [match_json_values(type: 'Move'), migration.account.id, 'http://example2.com'],
      ]
    end
  end
end
