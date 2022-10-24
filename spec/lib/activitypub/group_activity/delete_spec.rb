require 'rails_helper'

RSpec.describe ActivityPub::GroupActivity::Delete do
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

  let(:delete_json) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'foo',
      type: 'Delete',
      actor: ActivityPub::TagManager.instance.uri_for(sender),
      object: object_json,
    }.with_indifferent_access
  end

  before do
    group.memberships.create!(account: recipient, group: group)
  end

  describe '#perform' do
    subject { described_class.new(delete_json, sender) }

    context 'when the target is the group itself' do
      let(:object_json) { ActivityPub::TagManager.instance.uri_for(sender) }

      before do
        subject.perform
      end

      it 'deletes the group' do
        expect(Group.find_by(uri: group.uri)).to be_nil
      end
    end

    context 'when the target is another group' do
      let!(:other_group) { Fabricate(:group) }
      let(:object_json)  { ActivityPub::TagManager.instance.uri_for(other_group) }

      before do
        subject.perform
      end

      it 'deletes neither group' do
        expect(Group.find_by(uri: group.uri)).to_not be_nil
        expect(Group.find_by(id: other_group.id)).to_not be_nil
      end
    end
  end
end
