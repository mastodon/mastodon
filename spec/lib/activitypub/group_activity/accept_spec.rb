require 'rails_helper'

RSpec.describe ActivityPub::GroupActivity::Accept do
  let(:group)              { Fabricate(:group, domain: 'example.com', uri: 'https://example.com/groups/1') }
  let(:sender)             { group }
  let(:recipient)          { Fabricate(:account) }
  let(:membership_request) { Fabricate(:group_membership_request, account: recipient, group: group) }

  let(:member_json) do
    ActiveModelSerializers::SerializableResource.new(membership_request, serializer: ActivityPub::JoinSerializer, adapter: ActivityPub::Adapter).as_json
  end

  let(:accept_json) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'foo',
      type: 'Accept',
      actor: ActivityPub::TagManager.instance.uri_for(sender),
      object: member_json,
    }.with_indifferent_access
  end

  describe '#perform' do
    subject { described_class.new(accept_json, sender) }

    before do
      subject.perform
    end

    context 'when Accepting an embedded Join activity' do
      it 'creates a group membership' do
        expect(GroupMembership.where(account: recipient, group: group).exists?).to be true
      end

      it 'removes the group membership request' do
        expect(GroupMembershipRequest.where(account: recipient, group: group).exists?).to be false
      end
    end

    context 'when Accepting a Join activity referenced by URI' do
      let(:member_json) { membership_request.uri }

      it 'creates a group membership' do
        expect(GroupMembership.where(account: recipient, group: group).exists?).to be true
      end

      it 'removes the group membership request' do
        expect(GroupMembershipRequest.where(account: recipient, group: group).exists?).to be false
      end
    end

    context 'when the group accepting a Join is not the expected one' do
      let(:member_json) { membership_request.uri }
      let(:sender)      { Fabricate(:group) }

      it 'does not create a group membership' do
        expect(GroupMembership.where(account: recipient, group: group).exists?).to be false
      end

      it 'does not remove the group membership request' do
        expect(GroupMembershipRequest.where(account: recipient, group: group).exists?).to be true
      end
    end
  end
end
