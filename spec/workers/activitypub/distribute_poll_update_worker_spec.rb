# frozen_string_literal: true

require 'rails_helper'

describe ActivityPub::DistributePollUpdateWorker do
  subject { described_class.new }

  let(:account)  { Fabricate(:account) }
  let(:follower) { Fabricate(:account, protocol: :activitypub, inbox_url: 'http://example.com', domain: 'example.com') }
  let(:poll)     { Fabricate(:poll, account: account) }
  let!(:status)  { Fabricate(:status, account: account, poll: poll) }

  describe '#perform' do
    before do
      follower.follow!(account)
    end

    it 'delivers to followers' do
      expect_push_bulk_to_match(ActivityPub::DeliveryWorker, [[match_json_values(type: 'Update'), account.id, 'http://example.com']]) do
        subject.perform(status.id)
      end
    end
  end
end
