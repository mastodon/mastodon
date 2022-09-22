require 'rails_helper'

RSpec.describe ActivityPub::GroupActivity::Reject do
  let(:group)     { Fabricate(:group, domain: 'example.com', uri: 'https://example.com/groups/1') }
  let(:sender)    { group }
  let(:recipient) { Fabricate(:account) }

  let(:reject_json) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'foo',
      type: 'Reject',
      actor: ActivityPub::TagManager.instance.uri_for(group),
      object: object_json,
    }.with_indifferent_access
  end

  describe '#perform' do
    subject { described_class.new(reject_json, sender) }

    context 'when the rejected activity is a Join request' do
      let!(:membership_request) { Fabricate(:group_membership_request, account: recipient, group: group) }

      context 'when the object is embedded' do
        let(:object_json) do
          ActiveModelSerializers::SerializableResource.new(membership_request, serializer: ActivityPub::JoinSerializer, adapter: ActivityPub::Adapter).as_json
        end

        it 'does not create a membership' do
          subject.perform
          expect(GroupMembership.where(account: recipient, group: group).exists?).to be false
        end

        it 'removes the membership request' do
          expect { subject.perform }.to change { GroupMembershipRequest.where(account: recipient, group: group).exists? }.from(true).to(false)
        end
      end

      context 'when the object is referenced by URI' do
        let(:object_json) { membership_request.uri }

        it 'does not create a membership' do
          subject.perform
          expect(GroupMembership.where(account: recipient, group: group).exists?).to be false
        end

        it 'removes the membership request' do
          expect { subject.perform }.to change { GroupMembershipRequest.where(account: recipient, group: group).exists? }.from(true).to(false)
        end
      end

      context 'when the group rejecting a Join is not the expected one' do
        let(:object_json) { membership_request.uri }
        let(:sender)      { Fabricate(:group) }

        it 'does not create a group membership' do
          expect(GroupMembership.where(account: recipient, group: group).exists?).to be false
        end

        it 'does not remove the group membership request' do
          expect(GroupMembershipRequest.where(account: recipient, group: group).exists?).to be true
        end
      end
    end

    context 'when the rejected activity is a Create' do
      let!(:membership) { Fabricate(:group_membership, account: recipient, group: group) }
      let!(:status)     { Fabricate(:status, group: group, visibility: :group, account: recipient, approval_status: :pending) }

      context 'when the object is embedded' do
        let(:object_json) do
          ActiveModelSerializers::SerializableResource.new(ActivityPub::ActivityPresenter.from_status(status), serializer: ActivityPub::ActivitySerializer, adapter: ActivityPub::Adapter).as_json
        end

        it 'marks the status as rejected' do
          subject.perform
          expect(status.reload.rejected_approval?).to be true
        end
      end

      context 'when the object is referenced by URI' do
        let(:object_json) { ActivityPub::TagManager.instance.activity_uri_for(status) }

        it 'marks the status as rejected' do
          subject.perform
          expect(status.reload.rejected_approval?).to be true
        end
      end

      context 'when the group rejecting a Join is not the expected one' do
        let(:object_json) { ActivityPub::TagManager.instance.activity_uri_for(status) }
        let(:sender)      { Fabricate(:group) }

        it 'does not change the approval of the status' do
          expect { subject.perform }.to_not change { status.reload.approval_status }
        end
      end
    end
  end
end
