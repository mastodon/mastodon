require 'rails_helper'

RSpec.describe ActivityPub::GroupActivity::Add do
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

  let(:add_json) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'foo',
      type: 'Add',
      actor: ActivityPub::TagManager.instance.uri_for(sender),
      target: target_json,
      object: object_json,
    }.with_indifferent_access
  end

  before do
    group.memberships.create!(account: recipient, group: group)
  end

  describe '#perform' do
    subject { described_class.new(add_json, sender) }

    context 'when the target is the group wall' do
      let(:writer)      { Fabricate(:account, domain: 'remote.com', uri: 'https://remote.com/users/1') }
      let(:target_json) { group.wall_url }
      let(:object_json) { note_json[:id] }

      let(:note_json) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'https://remote.com/users/1/statuses/1',
          type: 'Note',
          attributedTo: writer.uri,
          content: 'first group post, woohoo!',
          to: note_to,
          target: note_target,
        }
      end

      context 'when the Note explicitly targets the group' do
        let(:note_target) { group.wall_url }
        let(:note_to)     { [group.members_url] }

        before do
          stub_request(:get, note_json[:id]).to_return(body: Oj.dump(note_json), headers: { 'Content-Type' => 'application/activity+json' })
          subject.perform
        end

        it 'creates a post' do
          expect(Status.find_by(uri: note_json[:id])).to_not be_nil
        end

        it 'creates a post with the expected group and visibility' do
          status = Status.find_by(uri: note_json[:id])
          expect(status.group).to eq group
          expect(status.visibility.to_sym).to eq :group
        end
      end

      context 'when the object is a local post' do
        let!(:membership) { Fabricate(:group_membership, group: group) }
        let!(:status) { Fabricate(:status, account: membership.account, group: group, visibility: :group, approval_status: :pending) }
        let(:object_json) { ActivityPub::TagManager.instance.uri_for(status) }

        it 'changes the status to approved' do
          expect { subject.perform }.to change { status.reload.approved? }.from(false).to(true)
        end
      end

      context 'when the object is a local post on a different group' do
        let!(:other_group) { Fabricate(:group) }
        let!(:membership) { Fabricate(:group_membership, group: other_group) }
        let!(:status) { Fabricate(:status, account: membership.account, group: other_group, visibility: :group, approval_status: :pending) }
        let(:object_json) { ActivityPub::TagManager.instance.uri_for(status) }

        it 'does not change the post approval' do
          expect { subject.perform }.to_not change { status.reload.approved? }
        end
      end

      context 'when the Note does not target the group' do
        let(:note_target) { nil }
        let(:note_to)     { [group.members_url] }

        before do
          stub_request(:get, note_json[:id]).to_return(body: Oj.dump(note_json), headers: { 'Content-Type' => 'application/activity+json' })
          subject.perform
        end

        it 'does not create a post' do
          expect(Status.find_by(uri: note_json[:id])).to be_nil
        end
      end

      context 'when the Note targets a different group' do
        let(:other_group) do
          Fabricate(:group,
            domain: 'mastodon.social',
            uri: 'https://mastodon.social/groups/1',
            wall_url: 'https://mastodon.social/groups/1/wall',
            members_url: 'https://mastodon.social/groups/1/members'
          )
        end

        let(:note_target) { other_group.wall_url }
        let(:note_to)     { [other_group.members_url] }

        before do
          stub_request(:get, note_json[:id]).to_return(body: Oj.dump(note_json), headers: { 'Content-Type' => 'application/activity+json' })
          subject.perform
        end

        it 'does not create a post' do
          expect(Status.find_by(uri: note_json[:id])).to be_nil
        end
      end
    end

    context 'when the target is the group members collection', skip: 'TODO' do
    end
  end
end
