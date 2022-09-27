require 'rails_helper'

describe ActivityPub::GroupUpdateDistributionWorker do
  subject { described_class.new }

  let(:group)  { Fabricate(:group) }
  let(:member) { Fabricate(:account, protocol: :activitypub, inbox_url: 'http://example.com') }

  describe '#perform' do
    before do
      group.memberships.create!(account: member)
    end

    it 'delivers to members' do
      expect_push_bulk_to_match(ActivityPub::GroupDeliveryWorker, [[kind_of(String), group.id, 'http://example.com', anything]])
      subject.perform(group.id)
    end
  end
end
