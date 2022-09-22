require 'rails_helper'

RSpec.describe ActivityPub::GroupActivity::Remove do
  let(:group) do
    Fabricate(:group,
      domain: 'example.com',
      uri: 'https://example.com/groups/1',
      wall_url: 'https://example.com/groups/1/wall',
      members_url: 'https://example.com/groups/1/members'
    )
  end

  let(:sender)    { group }
  let(:recipient) { Fabricate(:account) }

  let(:remove_json) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'foo',
      type: 'Remove',
      actor: ActivityPub::TagManager.instance.uri_for(sender),
      target: target_json,
      object: object_json,
    }.with_indifferent_access
  end

  before do
    group.memberships.create!(account: recipient, group: group)
  end

  describe '#perform' do
    subject { described_class.new(remove_json, sender) }

    context 'when the target is the group wall' do
      let(:writer)      { Fabricate(:account, domain: 'remote.com', uri: 'https://remote.com/users/1') }
      let(:target_json) { group.wall_url }
      let(:object_json) { ActivityPub::TagManager.instance.uri_for(status) }

      context 'when the post is a remote group post' do
        let(:status) { Fabricate(:status, account: writer, group: group, visibility: :group, uri: 'https://remote.com/users/1/statuses/1') }

        before do
          subject.perform
        end

        it 'deletes the post' do
          expect(Status.find_by(uri: status.uri)).to be_nil
        end
      end

      context 'when the post is a local group post', pending: 'TODO: soft-deletion / rejected flag' do
        let(:writer) { Fabricate(:account) }
        let(:status) { Fabricate(:status, account: writer, group: group, visibility: :group) }

        before do
          subject.perform
        end

        it 'deletes the post' do
          expect(Status.find_by(id: status.id)).to be_nil
        end
      end

      context 'when the post is not a group post' do
        let(:status) { Fabricate(:status, account: writer, uri: 'https://remote.com/users/1/statuses/1') }

        before do
          subject.perform
        end

        it 'does not delete the post' do
          expect(Status.find_by(uri: status.uri)).to_not be_nil
        end
      end
    end

    context 'when the target is the group members collection' do
      let(:target_json) { group.members_url }
      let(:object_json) { ActivityPub::TagManager.instance.uri_for(recipient) }

      it "removes the user from the group's members" do
        expect { subject.perform }.to change { group.members.where(id: recipient.id).exists? }.from(true).to(false)
      end
    end
  end
end
